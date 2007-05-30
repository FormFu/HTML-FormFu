package 
    HTMLFormFu::ElementSetup;

use strict;
use warnings;

use base 'HTML::FormFu::Element::text';

sub setup {
    my ( $self ) = @_;
    
    $::name = $self->name;
}

1;
