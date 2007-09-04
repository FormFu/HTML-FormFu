package HTML::FormFu::Element::File;

use strict;
use base 'HTML::FormFu::Element::_Input';
use Class::C3;

sub new {
    my $self = shift->next::method(@_);

    $self->field_type('file');

    $self->form->enctype('multipart/form-data');

    return $self;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::File - File upload form field

=head1 SYNOPSIS

    my $e = $form->element( File => 'foo' );

=head1 DESCRIPTION

File upload form field.

=head1 METHODS

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::_Input>, 
L<HTML::FormFu::Element::_Field>, 
L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
