package 
    HTMLFormFu::TestLib;

use strict;
use warnings;

sub mock_query {
    my ( $self, $query ) = @_;
    
    return HTMLFormFu::MockObject->new( $query );
}

####

package 
    HTMLFormFu::MockObject;

use strict;
use warnings;

sub new {
    my ( $class, $query ) = @_;
    
    die "query must be a hashref"
        unless ref($query) eq 'HASH';
    
    return bless $query, $class;
}

sub param {
    my ( $self, $param, $value ) = @_;
    
    if ( @_ == 1 ) {
        return keys %$self;
    }
    elsif ( @_ == 3 ) {
        $self->{$param} = $value;
        return $self->{$param};
    }
    else {
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
} 

1;
