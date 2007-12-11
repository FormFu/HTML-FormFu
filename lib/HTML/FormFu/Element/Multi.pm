package HTML::FormFu::Element::Multi;

use strict;
use base 'HTML::FormFu::Element::Block';
use Class::C3;

use HTML::FormFu::Element::_Field qw/
    _render_container_class _render_comment_class _render_label
    _string_field_start _string_field_end _string_label /;

use HTML::FormFu::Util qw/ append_xml_attribute xml_escape process_attrs /;
use List::MoreUtils qw/ uniq /;
use Storable qw/ dclone /;

__PACKAGE__->mk_accessors(
    qw/
        field_filename
        label_filename
        javascript
        container_tag
        label_tag
        /
);

__PACKAGE__->mk_output_accessors(
    qw/
        comment label value
        /
);

__PACKAGE__->mk_attrs(
    qw/
        comment_attributes
        container_attributes
        label_attributes
        /
);

sub new {
    my $self = shift->next::method(@_);

    $self->comment_attributes(   {} );
    $self->container_attributes( {} );
    $self->element_defaults(     {} );
    $self->filename('multi');
    $self->label_attributes( {} );
    $self->label_filename('label');
    $self->label_tag('label');
    $self->container_tag('span');

    return $self;
}

sub render_data_non_recursive {
    my $self = shift;

    my $render = $self->next::method( {
            comment_attributes   => xml_escape( $self->comment_attributes ),
            container_attributes => xml_escape( $self->container_attributes ),
            label_attributes     => xml_escape( $self->label_attributes ),
            comment              => xml_escape( $self->comment ),
            label                => xml_escape( $self->label ),
            field_filename       => $self->field_filename,
            label_filename       => $self->label_filename,
            label_tag            => $self->label_tag,
            container_tag        => $self->container_tag,
            javascript           => $self->javascript,
            @_ ? %{ $_[0] } : () } );

    $self->_render_container_class($render);

    $self->_render_comment_class($render);

    $self->_render_label($render);

    $self->_render_error_class($render);

    append_xml_attribute( $render->{attributes}, 'class', 'elements' );

    return $render;
}

sub _render_error_class {
    my ( $self, $render ) = @_;

    my @errors = map { @{ $_->get_errors } } @{ $self->_elements };

    if (@errors) {
        $render->{errors} = \@errors;

        append_xml_attribute( $render->{container_attributes},
            'class', 'error' );

        my @class = uniq sort map { $_->class } @errors;

        for my $class (@class) {
            append_xml_attribute( $render->{container_attributes},
                'class', $class );
        }
    }

    return;
}

sub string {
    my ( $self, $args ) = @_;

    $args ||= {};

    my $render
        = exists $args->{render_data}
        ? $args->{render_data}
        : $self->render_data_non_recursive;

    # field wrapper template - start

    my $html = $self->_string_field_start($render);

    # multi template

    $html .= sprintf "<span%s>\n", process_attrs( $render->{attributes} );

    for my $elem ( @{ $self->get_elements } ) {
        my $render = $elem->render_data;

        next if !defined $render;

        if ( $elem->reverse_multi ) {
            $html .= $elem->_string_field($render);

            if ( defined $elem->label ) {
                $html .= "\n" . $elem->_string_label($render);
            }
        }
        else {
            if ( defined $elem->label ) {
                $html .= $elem->_string_label($render) . "\n";
            }

            $html .= $elem->_string_field($render);
        }

        $html .= "\n";
    }

    $html .= "</span>";

    # field wrapper template - end

    $html .= $self->_string_field_end($render);

    return $html;
}

sub clone {
    my $self = shift;

    my $clone = $self->next::method(@_);

    $clone->comment_attributes( dclone $self->comment_attributes );
    $clone->container_attributes( dclone $self->container_attributes );
    $clone->label_attributes( dclone $self->label_attributes );

    return $clone;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::Multi - Combine multiple fields in a single element

=head1 SYNOPSIS

    my $e = $form->element( Multi => 'foo' );

=head1 DESCRIPTION

Combine multiple form fields in a single logical element.

=head1 METHODS

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::_Field>, 
L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
