package 
    HTMLFormFu::MyValidator;

use strict;
use warnings;

use base 'HTML::FormFu::Validator';

sub validate_value {
    my ( $self, $value, $params ) = @_;
    
    die HTML::FormFu::Exception::Validator->new
        if $value eq 'foo';
    
    return 1;
}

1;
