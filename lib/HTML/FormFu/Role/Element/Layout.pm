package HTML::FormFu::Role::Element::Layout;
use Moose::Role;
use MooseX::Attribute::Chained;

use Carp qw( carp croak );
use List::MoreUtils qw( first_index );
use Scalar::Util qw( reftype );

use HTML::FormFu::Util qw( process_attrs );

has layout_errors_filename     => ( is => 'rw', traits => ['Chained'], default => 'field_layout_errors' );
has layout_label_filename      => ( is => 'rw', traits => ['Chained'], default => 'field_layout_label' );
has layout_field_filename      => ( is => 'rw', traits => ['Chained'], default => 'field_layout_field' );
has layout_comment_filename    => ( is => 'rw', traits => ['Chained'], default => 'field_layout_comment' );
has layout_javascript_filename => ( is => 'rw', traits => ['Chained'], default => 'field_layout_javascript' );
has layout_label_text_filename => ( is => 'rw', traits => ['Chained'], default => 'field_layout_label_text' );
has layout_block_filename      => ( is => 'rw', traits => ['Chained'], default => 'field_layout_block' );

has layout_parser_filename     => ( is => 'rw', traits => ['Chained'], default => 'field_layout_parser' );

has _layout => (
    is => 'rw',
    default => sub {
        return [
            'errors',
            'label',
            'field',
            'comment',
            'javascript',
        ];
    },
);

# if we ever remove the reverse_single() method, we can make layout()
# a standard Moose attribute

sub layout {
    my $self = shift;

    if ( @_ ) {
        $self->_layout(@_);
        return $self;
    }

    my $value = $self->_layout;

    if ( defined $value && $self->reverse_single ) {
        # if it's an array-ref,
        # and 'label' and 'field' are consecutive values (in any order)
        # then just swap them around
        # otherwise warn that reverse_single() is deprecated

        my ( $ok, $field_index, $label_index );

        if ( ref $value && 'ARRAY' eq reftype($value) ) {
            $field_index = first_index { 'field' eq $_ } @$value;
            $label_index = first_index { 'label' eq $_ } @$value;

            if ( defined $field_index
                && defined $label_index
                && 1 == abs( $field_index - $label_index )
            ) {
                $ok = 1;
            }
        }

        if ($ok) {
            # create new arrayref so we don't change the stored value
            $value = [ @$value ];

            @$value[$field_index] = 'label';
            @$value[$label_index] = 'field';
        }
        else {
            carp "reverse_single() is deprecated, and is having no affect.";
        }
    }

    return $value;
}

has _multi_layout => (
    is => 'rw',
    default => sub {
        return [
            'label',
            'field',
        ];
    },
);

# if we ever remove the reverse_multi() method, we can make multi_layout()
# a standard Moose attribute

sub multi_layout {
    my $self = shift;

    if ( @_ ) {
        $self->_multi_layout(@_);
        return $self;
    }

    my $value = $self->_multi_layout;

    if ( defined $value && $self->reverse_multi ) {
        # if it's an array-ref,
        # and 'label' and 'field' are consecutive values (in any order)
        # then just swap them around
        # otherwise warn that reverse_multi() is deprecated

        my ( $ok, $field_index, $label_index );

        if ( ref $value && 'ARRAY' eq reftype($value) ) {
            $field_index = first_index { 'field' eq $_ } @$value;
            $label_index = first_index { 'label' eq $_ } @$value;

            if ( defined $field_index
                && defined $label_index
                && 1 == abs( $field_index - $label_index )
            ) {
                $ok = 1;
            }
        }

        if ($ok) {
            # create new arrayref so we don't change the stored value
            $value = [ @$value ];

            @$value[$field_index] = 'label';
            @$value[$label_index] = 'field';
        }
        else {
            carp "reverse_multi() is deprecated, and is having no affect.";
        }
    }

    return $value;
}

after BUILD => sub {
    my $self = shift;

    $self->filename('field_layout');

    return;
};

around render_data_non_recursive => sub {
    my ( $orig, $self, $args ) = @_;

    my $render = $self->$orig( {
            layout                     => $self->layout,
            multi_layout               => $self->multi_layout,
            layout_errors_filename     => $self->layout_errors_filename,
            layout_label_filename      => $self->layout_label_filename,
            layout_field_filename      => $self->layout_field_filename,
            layout_comment_filename    => $self->layout_comment_filename,
            layout_javascript_filename => $self->layout_javascript_filename,
            layout_label_text_filename => $self->layout_label_text_filename,
            layout_block_filename      => $self->layout_block_filename,
            layout_parser_filename     => $self->layout_parser_filename,
            $args ? %$args : (),
        } );

    return $render;
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
