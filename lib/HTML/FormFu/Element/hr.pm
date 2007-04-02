package HTML::FormFu::Element::hr;

use strict;
use warnings;
use base 'HTML::FormFu::Element::non_block';

sub new {
    my $self = shift->SUPER::new(@_);

    $self->tag('hr');

    return $self;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::hr

=head1 DESCRIPTION

Horizontal-rule element.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::non_block>, L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
