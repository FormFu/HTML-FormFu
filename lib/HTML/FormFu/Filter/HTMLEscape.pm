use strict;

package HTML::FormFu::Filter::HTMLEscape;

# ABSTRACT: filter escaping HTML

use Moose;
extends 'HTML::FormFu::Filter';

sub filter {
    my ( $self, $value ) = @_;

    return if !defined $value;

    $value =~ s/&(?!(amp|lt|gt|quot);)/&amp;/g;
    $value =~ s/</&lt;/g;
    $value =~ s/>/&gt;/g;
    $value =~ s/"/&quot;/g;

    return $value;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 DESCRIPTION

HTML escaping filter.

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

Based on the original source code of L<HTML::Widget::Filter::HTMLEscape>, by
Lyo Kato, C<lyo.kato@gmail.com>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
