package HTML::FormFu::Element::Button;

use Moose;

extends 'HTML::FormFu::Element';

with 'HTML::FormFu::Role::Element::Input';

after BUILD => sub {
    my ( $self, $args ) = @_;

    $self->field_type('button');
    $self->force_default(1);

    return;
};

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::Element::Button - Button form field

=head1 SYNOPSIS

    $e = $form->element( Button => 'foo' );

=head1 DESCRIPTION

Button form field, and base-class for L<HTML::FormFu::Element::Image>, 
L<HTML::FormFu::Element::Reset>, 
L<HTML::FormFu::Element::Submit>

=head1 METHODS

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Role::Element::Input>, 
L<HTML::FormFu::Role::Element::Field>, 
L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
