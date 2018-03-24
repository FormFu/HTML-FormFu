use strict;
package HTML::FormFu::Filter::NonNumeric;
# ABSTRACT: filter removing all non-numeric characters


use Moose;
extends 'HTML::FormFu::Filter::Regex';

sub match {qr/\D+/}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 DESCRIPTION

Remove all non-numeric characters.

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
