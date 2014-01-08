package HTML::FormFu::Role::Element::Layout;
use Moose::Role;
use Carp qw( croak );
use HTML::FormFu::Util qw( process_attrs );

has layout => ( is => 'rw' );

has multi_layout => (
    is => 'rw',
    default => sub { ['label', 'field'] },
);

after BUILD => sub {
    my $self = shift;

    $self->layout( [
        'errors',
        'label',
        'field',
        'comment',
        'javascript',
    ] );

    return;
};

sub string {
    my ( $self, $args ) = @_;

    $args ||= {};

    my $render
        = exists $args->{render_data}
        ? $args->{render_data}
        : $self->render_data;

    my $layout
        = exists $args->{layout}
        ? $args->{layout}
        : $self->layout;

    my $html = "";

    if ( defined $render->{container_tag} ) {
        $html .= sprintf "<%s%s>\n",
            $render->{container_tag},
            process_attrs( $render->{container_attributes} );
    }

    $html .= $self->_parse_layout( $render, $layout );

    if ( defined $render->{container_tag} ) {
        $html .= sprintf "\n</%s>", $render->{container_tag},;
    }

    return $html;
}

sub _parse_layout {
    my ( $self, $render, $layout ) = @_;

    croak "undefined 'layout'" if !defined $layout;

    my $html = "";

    if ( ref $layout && 'ARRAY' eq ref $layout ) {
        my @item_html;
        for my $item ( @$layout ) {
            push @item_html, $self->_parse_layout( $render, $item );
        }
        $html .=
            join "\n",
            grep {
                defined && length
            }
                @item_html;
    }
    elsif ( ref $layout && 'HASH' eq ref $layout ) {
        my ( $key, $value ) = %$layout;

        if ( my $method = $self->can( "_parse_layout_$key" ) ) {
            $html .= $self->$method( $render, $key, $value );
        }
        else {
            $html .= $self->_parse_layout_block( $render, $key, $value );
        }
    }
    elsif ( my $method = $self->can( "_parse_layout_$layout" ) ) {
        $html .= $self->$method( $render );
    }
    else {
        croak "Unknown layout() option: '$layout'";
    }

    return $html;
}

sub _parse_layout_errors {
    my ( $self, $render ) = @_;

    return $self->_string_errors( $render );
}

sub _parse_layout_label {
    my $self   = shift;
    my $render = shift;

    return "" unless exists $render->{label} && length $render->{label};

    if ( @_ ) {
        my ( $tag, @content ) = @_;

        return $self->_parse_layout_block(
            $render,
            $tag,
            {
                attributes => $render->{label_attributes},
                content    => \@content,
            },
        );
    }
    else {
        return $self->_string_label( $render );
    }
}

sub _parse_layout_field {
    my ( $self, $render ) = @_;

    return $self->_string_field( $render );
}

sub _parse_layout_comment {
    my ( $self, $render ) = @_;

    return "" if !defined $render->{comment};

    my $html = sprintf "<%s%s>\n%s\n</%s>",
        'span',
        process_attrs( $render->{comment_attributes} ),
        $render->{comment},
        'span';

    return $html;
}

sub _parse_layout_javascript {
    my ( $self, $render ) = @_;

    return "" if !defined $render->{javascript};

    my $html = sprintf qq{<script type="text/javascript">\n%s\n</script>},
        $render->{javascript};

    return $html;
}

sub _parse_layout_label_text {
    my ( $self, $render ) = @_;

    return "" unless exists $render->{label} && length $render->{label};

    return $render->{label};
}

sub _parse_layout_block {
    my ( $self, $render, $tag, $opts ) = @_;

    $opts ||= {};

    my $html = "<$tag";

    if ( $opts->{attributes} ) {
        $html .= process_attrs( $opts->{attributes} );
    }

    $html .= ">\n";

    if ( $opts->{content} ) {
        $html .= $self->_parse_layout( $render, $opts->{content} );
    }

    $html .= "\n</$tag>";

    return $html;
}

1;
