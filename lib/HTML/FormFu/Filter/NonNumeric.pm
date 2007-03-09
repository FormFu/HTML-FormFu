package HTML::FormFu::Filter::NonNumeric;

use strict;
use warnings;
use base 'HTML::FormFu::Filter::Regex';

sub match {qr/\D+/}

1;

__END__

=head1 NAME

HTML::FormFu::Filter::NonNumeric - Non-numeric character removing filter

=head1 SYNOPSIS

    $form->filter( NonNumeric => 'foo' );

=head1 DESCRIPTION

Non-numeric character removing filter.

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
