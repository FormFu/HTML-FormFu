package HTML::FormFu::Element::Multi;

use strict;
use warnings;
use base 'HTML::FormFu::Element::Block';
use Class::C3;

use HTML::FormFu::Element::_Field qw/
    _render_container_class _render_comment_class _render_label /;
use HTML::FormFu::Util qw/ append_xml_attribute xml_escape /;
use List::MoreUtils qw/ uniq /;
use Storable qw/ dclone /;

__PACKAGE__->mk_accessors(
    qw/
        field_filename
        label_filename
        javascript
        container_tag
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
    $self->container_tag('span');
    $self->render_class_suffix('multi');

    return $self;
}

sub render {
    my $self = shift;

    my $render = $self->next::method( {
            comment_attributes   => xml_escape( $self->comment_attributes ),
            container_attributes => xml_escape( $self->container_attributes ),
            label_attributes     => xml_escape( $self->label_attributes ),
            comment              => xml_escape( $self->comment ),
            label                => xml_escape( $self->label ),
            field_filename       => $self->field_filename,
            label_filename       => $self->label_filename,
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

    my $e = $form->element( multi 'foo' );

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
