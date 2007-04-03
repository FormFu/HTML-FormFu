package HTML::FormFu::Element::reset;

use strict;
use warnings;
use base 'HTML::FormFu::Element::button';

sub new {
    my $self = shift->SUPER::new(@_);

    $self->field_type('reset');

    return $self;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::Reset - Reset button form field

=head1 SYNOPSIS

    $e = $form->element( Reset => 'foo' );

=head1 DESCRIPTION

Reset button form field.

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
