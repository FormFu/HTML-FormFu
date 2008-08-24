package HTML::FormFu::Constraint::Word;

use strict;
use base 'HTML::FormFu::Constraint::Regex';

sub regex {
    return qr/^\w*\z/;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::Word - Single Word Constraint

=head1 DESCRIPTION

Ensure the input is a single word. Which characters are considered "word 
characters" will depend on the current locale.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint::Regex>,
L<HTML::FormFu::Constraint>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
