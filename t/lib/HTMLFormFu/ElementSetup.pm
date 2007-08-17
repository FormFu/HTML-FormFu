package 
    HTMLFormFu::ElementSetup;

use strict;
use warnings;

use base 'HTML::FormFu::Element::Text';

sub setup {
    my ( $self ) = @_;
    
    $::name = $self->name;
}

1;
