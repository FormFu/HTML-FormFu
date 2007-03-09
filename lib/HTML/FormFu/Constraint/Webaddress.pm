package HTML::FormFu::Constraint::Webaddress;

use strict;
use warnings;
use base 'HTML::FormFu::Constraint::Regex';

use Regexp::Common qw /URI/;

sub regex {
    my $http_uri = $RE{URI}{HTTP}{-scheme=>'https?'};

    return qr/^$http_uri\z/;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::Webaddress - Webaddress constraint

=head1 SYNOPSIS

    $form->constraint( Webaddress => 'foo' );

=head1 DESCRIPTION

Webaddress constraint.

Checks if the given string looks somehow like a webaddress.

It accepts http://www.perl.org and https://www.perl.org syle addresses, also addresses with path and query.

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint::Regex>

=head1 Known Problems

Due to the usage of L<Regexp::Common> the matching is not 100% correct.

The following URLs are accepted:
http://www.perl.org./ (with point after the top level)
http://1234.1234.1234.1234/ (the checking of IPv4 addresses is very sloppy ('[0-9]+[.][0-9]+[.][0-9]+[.][0-9]+')

=head1 AUTHOR

Mario Minati C<mario@minati.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
