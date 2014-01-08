package HTML::FormFu::Element::Textarea;
use Moose;

extends "HTML::FormFu::Element";

with 'HTML::FormFu::Role::Element::Field',
    'HTML::FormFu::Role::Element::SingleValueField';

use HTML::FormFu::Util qw( process_attrs );

__PACKAGE__->mk_attr_accessors(qw(
    autocomplete
    cols
    maxlength
    rows
    placeholder
));

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

    my $html = sprintf qq{<textarea name="%s"%s>},
        $render->{nested_name},
        process_attrs( $render->{attributes} ),
        ;

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

=head1 ATTRIBUTE ACCESSORS

Get / set input attributes directly with these methods.

Arguments: [$string]

Return Value: $string

=head2 autocomplete

=head2 cols

=head2 maxlength

=head2 rows

=head2 placeholder

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Role::Element::Field>, 
L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
