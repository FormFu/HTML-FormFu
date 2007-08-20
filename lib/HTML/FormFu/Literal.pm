package HTML::FormFu::Literal;

use strict;
use warnings;

use overload
    '""'     => sub { return join "", @{ $_[0] } },
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
