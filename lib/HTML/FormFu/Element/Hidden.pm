package HTML::FormFu::Element::Hidden;

use strict;
use base 'HTML::FormFu::Element::_Input';
use Class::C3;

sub new {
    my $self = shift->next::method(@_);

    $self->field_type('hidden');
    $self->filename('input_tag');

    return $self;
}

sub string {
    my ( $self, $args ) = @_;

    $args ||= {};

    my $render
        = exists $args->{render_data}
        ? $args->{render_data}
        : $self->render_data;

    # input template

    my $html .= $self->_string_field($render);

    return $html;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::Hidden - Hidden form field

=head1 SYNOPSIS

    my $e = $form->element( Hidden => 'foo' );

=head1 DESCRIPTION

Hidden form field.

=head1 METHODS

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::_Input>, 
L<HTML::FormFu::Element::_Field>, 
L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
