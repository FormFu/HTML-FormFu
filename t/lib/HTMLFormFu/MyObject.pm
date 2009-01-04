package 
    HTMLFormFu::MyObject;

use strict;
use warnings;
use Carp qw( confess );

#use overload
#    '""' => sub { confess "overload called on object" },
#    bool => sub { 1 },
#    fallback => 1;

sub new {
    my ( $class, $value ) = @_;
    
    return bless { value => $value }, $class;
}

1;
