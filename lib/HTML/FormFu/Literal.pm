package HTML::FormFu::Literal;

use strict;
use HTML::FormFu::Constants qw( $EMPTY_STR );

use overload
    '""'     => sub { return join $EMPTY_STR, @{ $_[0] } },
    fallback => 1;

sub new {
    my $class = shift;

    return bless \@_, $class;
}

sub push {
    my ( $self, @args ) = @_;

    CORE::push( @{ $_[0] }, @args );
}

sub unshift {
    my ( $self, @args ) = @_;

    CORE::unshift( @{ $_[0] }, @args );
}

1;
