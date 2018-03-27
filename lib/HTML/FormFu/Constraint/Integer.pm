use strict;

package HTML::FormFu::Constraint::Integer;

# ABSTRACT: Unsigned Integer Constraint

use Moose;
extends 'HTML::FormFu::Constraint::Regex';

sub regex {qr/^[0-9]*\z/}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 DESCRIPTION

Integer constraint.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint::Regex>,
L<HTML::FormFu::Constraint>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

Based on the original source code of L<HTML::Widget::Constraint::Integer>, by
Sebastian Riedel, C<sri@oook.de>.

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
