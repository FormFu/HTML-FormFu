use strict;
use warnings;

use Test::More tests => 1;

use lib 't/lib';
use HTML::FormFu;

$::name = undef;

my $form = HTML::FormFu->new( { auto_fieldset => 1, } );

$form->element( {
        type => '+HTMLFormFu::ElementSetup',
        name => 'xxx',
    } );

is( $::name, 'xxx', 'setup ran and had access to $self->name' );
