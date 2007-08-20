package HTML::FormFu::Filter::Regex;

use strict;
use warnings;
use base 'HTML::FormFu::Filter';

__PACKAGE__->mk_accessors(qw/ match replace /);

sub filter {
    my ( $self, $value ) = @_;

    return if !defined $value;

    my $match   = $self->match;
    my $replace = $self->replace;

    $match   = qr/./ if !defined $match;
    $replace = ''    if !defined $replace;

    $value =~ s/$match/$replace/g;

    return $value;
}

1;

__END__

=head1 NAME

HTML::FormFu::Filter::Regex

=head1 SYNOPSIS

The following filter would turn C<1234-5678> into C<****-****>.

    type: Regex
    match: \d
    replace: *

=head1 DESCRIPTION

Regular expression-based match / replace filter.

=head1 METHODS

=head2 match

A regex object or string to be used in the "left-hand side" of a C<s///g> 
regular expression.

Default Value: qr/./

=head2 replace

A string to be used in the "right-hand side" of a C<s///g> regular 
expression. The string will replace every occurance of L</match>.

Default Value: ''

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
