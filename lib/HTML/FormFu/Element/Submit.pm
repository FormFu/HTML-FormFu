package HTML::FormFu::Element::Submit;

use strict;
use base 'HTML::FormFu::Element::Button';
use Class::C3;

sub new {
    my $self = shift->next::method(@_);

    $self->field_type('submit');

    return $self;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::Submit - Submit button form field

=head1 SYNOPSIS

    $element = $form->element( Submit => 'foo' );

=head1 DESCRIPTION

Submit button form field.

=head1 METHODS

=head1 non_block

See L<HTML::FormFu::Elements::_Field/non_block> for details.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::Button>, 
L<HTML::FormFu::Element::_Input>, 
L<HTML::FormFu::Element::_Field>, 
L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
