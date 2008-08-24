package HTML::FormFu::Element::Hr;

use strict;
use base 'HTML::FormFu::Element::_NonBlock';
use Class::C3;

sub new {
    my $self = shift->next::method(@_);

    $self->tag('hr');

    return $self;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::Hr - horizontal-rule element

=head1 DESCRIPTION

Horizontal-rule element.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::NonBlock>, 
L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
