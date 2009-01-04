package 
    HTMLFormFu::MyDeflator;

use strict;
use warnings;

use base 'HTML::FormFu::Deflator';

sub deflator {
    my ( $self, $value ) = @_;
    
    return if !defined $value;
    
    return $value->{value};
}

1;
