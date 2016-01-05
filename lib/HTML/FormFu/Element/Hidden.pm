package HTML::FormFu::Element::Hidden;

use Moose;

extends 'HTML::FormFu::Element';

with 'HTML::FormFu::Role::Element::Input';

after BUILD => sub {
    my $self = shift;

    $self->field_type('hidden');
    $self->container_tag(undef);

    $self->layout( [
        'field',
    ] );

    return;
};

__PACKAGE__->meta->make_immutable;

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
