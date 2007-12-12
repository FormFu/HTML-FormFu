use strict;
use warnings;
use Test::More;

BEGIN {
    eval "use DBIx::Class 0.08002";
    if ($@) {
        plan skip_all => 'DBIx::Class required';
        exit;
    }
}

plan tests => 9;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/save_to_model/has_many_repeatable_new.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $user_rs = $schema->resultset('User');
my $address_rs = $schema->resultset('Address');


{
    # insert some entries we'll ignore, so our rels don't have same ids
    # user 1
    my $u1 = $user_rs->new_result({ name => 'foo' });
    $u1->insert;
    # address 1
    my $a1 = $u1->new_related( 'addresses' => { address => 'somewhere' } );
    $a1->insert;
    
    # should get user id 2
    my $u2 = $user_rs->new_result({
        name => 'nick',
        });
    $u2->insert;
    
    # should get address id 2
    my $a2 = $u2->new_related( 'addresses', { address => 'home' } );
    $a2->insert;
    
    # should get address id 3
    my $a3 = $u2->new_related( 'addresses', { address => 'office' } );
    $a3->insert;
}

{
    $form->process({
        'id'    => 2,
        'name'  => 'new nick',
        'count' => 3,
        'addresses.id_1'      => 2,
        'addresses.address_1' => 'new home',
        'addresses.id_2'      => 3,
        'addresses.address_2' => 'new office',
        'addresses.id_3'      => '',
        'addresses.address_3' => 'new address',
    });
    
    ok( $form->submitted_and_valid );
    
    my $row = $user_rs->find(2);
    
    $form->save_to_model( $row );
    
    my $user = $user_rs->find(2);
    
    is( $user->name, 'new nick' );
    
    my @add = $user->addresses->all;
    
    is( scalar @add, 3 );
    
    is( $add[0]->id, 2 );
    is( $add[0]->address, 'new home' );
    
    is( $add[1]->id, 3 );
    is( $add[1]->address, 'new office' );
    
    is( $add[2]->id, 4 );
    is( $add[2]->address, 'new address' );
}

