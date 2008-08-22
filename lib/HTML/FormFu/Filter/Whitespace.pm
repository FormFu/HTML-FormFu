package HTML::FormFu::Filter::Whitespace;

use strict;
use base 'HTML::FormFu::Filter::Regex';

sub match {qr/\s+/}

1;

__END__

=head1 NAME

HTML::FormFu::Filter::Whitespace - filter stripping all whitespace

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
