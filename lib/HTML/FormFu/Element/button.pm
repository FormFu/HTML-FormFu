package HTML::FormFu::Element::button;

use strict;
use warnings;
use base 'HTML::FormFu::Element::input';

sub new {
    my $self = shift->SUPER::new(@_);

    $self->field_type('button');

    return $self;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::Button - Button form field

=head1 SYNOPSIS

    $e = $form->element( Button => 'foo' );

=head1 DESCRIPTION

Button form field, and base-class for L<HTML::FormFu::Element::Image>, 
L<HTML::FormFu::Element::Reset>, L<HTML::FormFu::Element::Submit>

=head1 METHODS

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Element::input>, 
L<HTML::FormFu::Element::field>, L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
