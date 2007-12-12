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

plan tests => 10;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/defaults_from_model/has_many_repeatable_new.yml');

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
    my $row = $user_rs->find(2);
    
    $form->defaults_from_model( $row );
    
    is( $form->get_field('id')->default, '2' );
    is( $form->get_field('name')->default, 'nick' );
    is( $form->get_field('count')->default, '3' );
    
    my $block = $form->get_all_element({ nested_name => 'addresses' });
    
    my @reps = @{ $block->get_elements };
    
    is( scalar @reps, 3 );
    
    is( $reps[0]->get_field('id_1')->default, '2' );
    is( $reps[0]->get_field('address_1')->default, 'home' );
    
    is( $reps[1]->get_field('id_2')->default, '3' );
    is( $reps[1]->get_field('address_2')->default, 'office' );
    
    is( $reps[2]->get_field('id_3')->default, undef );
    is( $reps[2]->get_field('address_3')->default, undef );
}

