package HTML::FormFu::Element::Textarea;
use Moose;

extends "HTML::FormFu::Element";

with 'HTML::FormFu::Role::Element::Field',
     'HTML::FormFu::Role::Element::SingleValueField' => { -excludes => 'nested_name' };

use HTML::FormFu::Util qw( process_attrs );

__PACKAGE__->mk_attr_accessors(qw( cols rows placeholder ));

after BUILD => sub {
    my $self = shift;

    $self->filename('input');
    $self->field_filename('textarea_tag');
    $self->cols(40);
    $self->rows(20);

    return;
};

sub string {
    my ( $self, $args ) = @_;

    $args ||= {};

    my $render
        = exists $args->{render_data}
        ? $args->{render_data}
        : $self->render_data;

    # field wrapper template - start

    my $html = $self->_string_field_start($render);

    # input_tag template

    $html .= $self->_string_field($render);

    # field wrapper template - end

    $html .= $self->_string_field_end($render);

    return $html;
}

sub _string_field {
    my ( $self, $render ) = @_;

    # textarea_tag template

    my $html .= "<textarea";

    $html .= sprintf qq{ name="%s"}, $render->{nested_name};

    if ( defined $self->placeholder ) {
        $html .= sprintf qq{ placeholder="%s"}, $self->placeholder;
    }

    $html .= process_attrs( $render->{attributes} );

    $html .= '>';

    if ( defined $render->{value} ) {
        $html .= $render->{value};
    }

    $html .= "</textarea>";

    return $html;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::Element::Textarea - Textarea form field

=head1 SYNOPSIS

    my $element = $form->element( Textarea => 'foo' );

=head1 DESCRIPTION

Textarea form field.

=head1 METHODS

=head2 cols

Sets the C<textarea> tag's C<cols> attribute.

=head2 rows

Sets the C<textarea> tag's C<rows> attribute.

=head2 placeholder

Sets the HTML5 attribute C<placeholder> to the specified value.

=head2 placeholder_xml

If you don't want the C<placeholder> attribute to be XML-escaped, use the L</placeholder_xml> 
method instead of L</placeholder>.

Arguments: $string

=head2 placeholder_loc

Arguments: $localization_key

Set the  C<placeholder> attribute using a L10N key.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::_Field>, 
L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
