use strict;

package HTML::FormFu::Filter::Whitespace;

# ABSTRACT: filter stripping all whitespace

use Moose;
extends 'HTML::FormFu::Filter::Regex';

sub match {qr/\s+/}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 DESCRIPTION

Removes all whitespace.

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

Based on the original source code of L<HTML::Widget::Filter::Whitespace>, by
Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
