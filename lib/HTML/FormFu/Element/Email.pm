package HTML::FormFu::Element::Email;
use Moose;

extends 'HTML::FormFu::Element';

with 'HTML::FormFu::Role::Element::Input';

after BUILD => sub {
    my $self = shift;

    $self->field_type('email');

    $self->constraint('Email');

    return;
};

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::Element::Email - HTML5 email form field

=head1 SYNOPSIS

    my $element = $form->element( Email => 'foo' );
    
    # no need to add a separate Constraint::Email

=head1 DESCRIPTION

HTML5 email form field which  provides native client-side validation in modern browsers.

Creates an input field with C<<type="email">>.

This element automatically adds an L<Email constraint|HTML::FormFu::Constraint::Email>,
so you don't have to.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Role::Element::Input>, 
L<HTML::FormFu::Role::Element::Field>, 
L<HTML::FormFu::Element>.

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
