package HTML::FormFu::Element::submit;

use strict;
use warnings;
use base 'HTML::FormFu::Element::button';

sub new {
    my $self = shift->SUPER::new(@_);

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

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Element::Button>, 
L<HTML::FormFu::Element::input>, L<HTML::FormFu::Element::field>, 
L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
