package HTML::FormFu::Filter::Split;

use strict;
use base 'HTML::FormFu::Filter';

__PACKAGE__->mk_item_accessors(qw( regex limit ));

sub filter {
    my ( $self, $value ) = @_;

    return if !defined $value;

    my $regex = $self->regex;
    my $limit = $self->limit || 0;

    $regex = '' if !defined $regex;

    my @values = split /$regex/, $value, $limit;

    return \@values;
}

1;

__END__

=head1 NAME

HTML::FormFu::Filter::Split - filter splitting a singe valut into an arrayref

=head1 SYNOPSIS

    type: Split
    regex: '-'

=head1 DESCRIPTION

Split a single input value into an arrayref of values.

=head1 METHODS

=head2 regex

A regex object or string to be passed as the C<PATTERN> argument to C<split>.

Default Value: '' (emtpy string)

=head2 limit

A number passed as the C<LIMIT> argument to C<split>.

Default Value: 0

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
