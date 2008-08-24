package HTML::FormFu::Constraint::ASCII;

use strict;
use base 'HTML::FormFu::Constraint::Regex';

sub regex {
    return qr/^\p{IsASCII}*\z/;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::ASCII - ASCII Characters Constraint

=head1 DESCRIPTION

Input value must only contain ASCII characters.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint::Regex>,
L<HTML::FormFu::Constraint>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
