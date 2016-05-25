package HTML::FormFu::Role::FormAndBlockMethods;

use strict;
# VERSION

use Moose::Role;

use HTML::FormFu::Util qw( _merge_hashes );
use Carp qw( croak );
use List::MoreUtils qw( none );

sub default_args {
    my ( $self, $defaults ) = @_;

    $self->{default_args} ||= {};

    if ($defaults) {

        my @valid_types = qw(
            elements        deflators
            filters         constraints
            inflators       validators
            transformers    output_processors
        );

        for my $type ( keys %$defaults ) {
            croak "not a valid type for default_args: '$type'"
                if none { $type eq $_ } @valid_types;
        }

        $self->{default_args}
            = _merge_hashes( $self->{default_args}, $defaults );
    }

    return $self->{default_args};
}

1;
