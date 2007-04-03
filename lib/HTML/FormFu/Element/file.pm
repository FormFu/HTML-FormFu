package HTML::FormFu::Element::file;

use strict;
use warnings;
use base 'HTML::FormFu::Element::input';

sub new {
    my $self = shift->SUPER::new(@_);

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

Is a sub-class of, and inherits methods from L<HTML::FormFu::Element::input>, 
L<HTML::FormFu::Element::field>, L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
