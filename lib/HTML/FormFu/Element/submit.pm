package HTML::FormFu::Element::submit;

use strict;
use warnings;
use base 'HTML::FormFu::Element::button';
use Class::C3;

sub new {
    my $self = shift->next::method(@_);

    $self->field_type('submit');

    return $self;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::submit - Submit button form field

=head1 SYNOPSIS

    $element = $form->element( Submit => 'foo' );

=head1 DESCRIPTION

Submit button form field.

=head1 METHODS

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::button>, 
L<HTML::FormFu::Element::_input>, 
L<HTML::FormFu::Element::_field>, 
L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
