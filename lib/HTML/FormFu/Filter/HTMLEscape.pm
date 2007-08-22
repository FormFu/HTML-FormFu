package HTML::FormFu::Filter::HTMLEscape;

use strict;
use base 'HTML::FormFu::Filter';

sub filter {
    my ( $self, $value ) = @_;

    return if !defined $value;

    $value =~ s/&(?!(amp|lt|gt|quot);)/&amp;/g;
    $value =~ s/</&lt;/g;
    $value =~ s/>/&gt;/g;
    $value =~ s/"/&quot;/g;

    return $value;
}

1;

__END__

=head1 NAME

HTML::FormFu::Filter::HTMLEscape

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
