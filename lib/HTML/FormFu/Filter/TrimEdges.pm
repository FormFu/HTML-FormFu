use strict;

package HTML::FormFu::Filter::TrimEdges;

# ABSTRACT: filter trimming whitespace

use Moose;
extends 'HTML::FormFu::Filter';

sub filter {
    my ( $self, $value ) = @_;

    return if !defined $value;

    $value =~ s/^\s+//;
    $value =~ s/\s+\z//;

    return $value;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 DESCRIPTION

Trim whitespaces from beginning and end of string.

=head1 AUTHOR

Mario Minati, C<mario@minati.de>

Based on the original source code of L<HTML::Widget::Filter::TrimEdges>, by
Sebastian Riedel, C<sri@oook.de>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it
under
the same terms as Perl itself.

=cut
