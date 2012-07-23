package HTMLFormFu::DBICUniqueFake;

use Moose;

extends 'HTML::FormFu::Constraint';

has id_field       => ( is => 'rw', traits  => ['Chained'] );

sub constrain_value {
    my ( $self, $value ) = @_;

    return 1 if !defined $value || $value eq '';

    return 1;
}

1;

