package HTML::FormFu::FakeQuery;
use strict;
use warnings;
use Carp qw/ croak /;

sub new {
    my ( $class, $param ) = @_;

    eval { my %x = %$param };
    croak 'argument must be a hashref' if $@;

    return bless $param, $class;
}

sub param {
    my $self = shift;

    if ( !@_ ) {
        return keys %$self;
    }
    elsif ( @_ == 2 ) {
        my ( $param, $value ) = @_;

        $self->{$param} = $value;
        return $self->{$param};
    }
    elsif ( @_ == 1 ) {
        my ($param) = @_;

        unless ( exists $self->{$param} ) {
            return wantarray ? () : undef;
        }
        if ( ref $self->{$param} eq 'ARRAY' ) {
            return (wantarray)
                ? @{ $self->{$param} }
                : $self->{$param}->[0];
        }
        else {
            return (wantarray)
                ? ( $self->{$param} )
                : $self->{$param};
        }
    }

    croak 'require arguments [$name, [$value]]';
}

# dummy methods, so FakeQuery doesn't cause fatal errors
# if a form is submitted

sub upload { }

sub uploadInfo{ {} }

1;
