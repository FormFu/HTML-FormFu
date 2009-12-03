package HTML::FormFu::FakeQuery;
use strict;
use Scalar::Util qw( reftype );
use Carp qw( croak );

sub new {
    my ( $class, $form, $param ) = @_;

    croak 'argument must be a hashref'
        if reftype( $param ) ne 'HASH';

    # handle pre-expanded input

    my @names
        = grep {defined}
        map    { $_->nested_name } @{ $form->get_fields };

    for my $name (@names) {
        next if exists $param->{$name};

        if ( $form->nested_hash_key_exists( $param, $name ) ) {
            $param->{$name} = $form->get_nested_hash_value( $param, $name );
        }
    }

    my $self = { _params => $param };

    return bless $self, $class;
}

sub param {
    my $self = shift;

    if ( !@_ ) {
        return keys %{ $self->{_params} };
    }
    elsif ( @_ == 2 ) {
        my ( $param, $value ) = @_;

        $self->{$param} = $value;
        return $self->{_params}{$param};
    }
    elsif ( @_ == 1 ) {
        my ($param) = @_;

        if ( !exists $self->{_params}{$param} ) {
            return wantarray ? () : undef;
        }

        if ( ref $self->{_params}{$param} eq 'ARRAY' ) {
            return (wantarray)
                ? @{ $self->{_params}{$param} }
                : $self->{_params}{$param}->[0];
        }
        else {
            return (wantarray)
                ? ( $self->{_params}{$param} )
                : $self->{_params}{$param};
        }
    }

    croak 'require arguments [$name, [$value]]';
}

# dummy methods, so FakeQuery doesn't cause fatal errors
# if a form is submitted

sub upload { }

sub uploadInfo { {} }

1;
