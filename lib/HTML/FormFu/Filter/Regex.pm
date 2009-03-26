package HTML::FormFu::Filter::Regex;

use strict;
use base 'HTML::FormFu::Filter';

use HTML::FormFu::Constants qw( $EMPTY_STR );

__PACKAGE__->mk_item_accessors(qw( match replace eval ));

sub filter {
    my ( $self, $value ) = @_;

    return if !defined $value;

    my $match   = defined $self->match   ? $self->match   : qr/./;
    my $replace = defined $self->replace ? $self->replace : $EMPTY_STR;

    if ( $self->eval ) {
        $value =~ s/$match/$replace/gee;
    }
    else {
        $value =~ s/$match/$replace/g;
    }

    return $value;
}

1;

__END__

=head1 NAME

HTML::FormFu::Filter::Regex - regexp-based match/replace filter

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

=head2 eval

Arguments: $bool

If true, the regex modifier C</e> is used, so that the contents of the
L</replace> string are C<eval>'d.

This allows the use of variables such as C<$1> or any other perl expression.

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
