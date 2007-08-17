package HTML::FormFu::Element::Src;

use strict;
use warnings;
use base 'HTML::FormFu::Element::Block';
use Class::C3;

sub new {
    my $self = shift->next::method(@_);

    $self->tag(undef);

    return $self;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::Src

=head1 DESCRIPTION

Allows you to add markup directly into the form, without surrounding 
C<< <div> </div> >> tags.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::Block>, 
L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
