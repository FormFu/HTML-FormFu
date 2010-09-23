package HTML::FormFu::Filter::HTMLScrubber;

use Moose;
extends 'HTML::FormFu::Filter';

use Clone ();

has allow   => ( is => 'rw', traits  => ['Chained'] );
has comment => ( is => 'rw', traits  => ['Chained'] );
has default => ( is => 'rw', traits  => ['Chained'] );
has rules   => ( is => 'rw', traits  => ['Chained'] );
has script  => ( is => 'rw', traits  => ['Chained'] );

use HTML::Scrubber;

sub filter {
    my ( $self, $value ) = @_;

    return if !defined $value;

    my %params = ( allow => 0 );
    foreach (qw(allow comment default rules script)) {
        my $val = $self->$_;
        $params{$_} = $val if ( defined($val) );
    }

    my $scrubber = HTML::Scrubber->new(%params);

    return $scrubber->scrub($value);
}

sub clone {
    my $self = shift;

    my $clone = $self->SUPER::clone(@_);

    $clone->allow( Clone::clone $self->allow )
        if ref $self->allow;

    return $clone;
}

1;

__END__

=head1 NAME

HTML::FormFu::Filter::HTMLScrubber - filter removing HTML markup

=head1 DESCRIPTION

Remove HTML markup using L<HTML::Scrubber>.

All the functionality of L<HTML::Scrubber> can be accessed using
this module, other than the C<process> directive (which has a name
clash with the L<HTML::FormFu::Filter> framework).

For details of the filtering functionality see
L<HTML::Scrubber/allow>, L<HTML::Scrubber/comment>,
L<HTML::Scrubber/default>, L<HTML::Scrubber/rules> and
L<HTML::Scrubber/script>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

Extended by Nigel Metheringham, C<nigelm@cpan.org>

Based on the original source code of L<HTML::Widget::Filter::HTMLStrip>, by 
Lyo Kato, C<lyo.kato@gmail.com>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
