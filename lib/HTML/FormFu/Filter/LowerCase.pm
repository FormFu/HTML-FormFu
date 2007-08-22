package HTML::FormFu::Filter::LowerCase;

use strict;
use base 'HTML::FormFu::Filter';

sub filter {
    my ( $self, $value ) = @_;

    return if !defined $value;

    return lc $value;
}

1;

__END__

=head1 NAME

HTML::FormFu::Filter::LowerCase

=head1 DESCRIPTION

LowerCase transforming filter.

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

Based on the original source code of L<HTML::Widget::Filter::LowerCase>, by 
Lyo Kato, C<lyo.kato@gmail.com>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
