package HTML::FormFu::FakeQuery;
use strict;
use Carp qw/ croak /;

sub new {
    my ( $class, $param ) = @_;

    eval { my %x = %$param };
    croak 'argument must be a hashref' if $@;

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

        unless ( exists $self->{_params}{$param} ) {
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
