use strict;
package HTML::FormFu::Filter::UpperCase;
# ABSTRACT: filter transforming to upper case


use Moose;
extends 'HTML::FormFu::Filter';

sub filter {
    my ( $self, $value ) = @_;

    return if !defined $value;

    return uc $value;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 DESCRIPTION

UpperCase transforming filter.

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

Based on the original source code of L<HTML::Widget::Filter::UpperCase>, by
Lyo Kato, C<lyo.kato@gmail.com>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
