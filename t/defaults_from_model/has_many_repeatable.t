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

plan tests => 8;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/defaults_from_model/has_many_repeatable.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $rs = $schema->resultset('User');

# filler

$rs->create({
    name => 'filler',
    addresses => [
    {
        address => 'somewhere',
    }
    ]
});

$rs->create({
    name => 'filler2',
});

$rs->create({
    name => 'filler3',
});

# row we're going to use

$rs->create({
    name => 'nick',
    addresses => [
    {
        address => 'home',
    },
    {
        address => 'office',
    }
    ]
});

{
    my $row = $rs->find(4);
    
    $form->defaults_from_model( $row );
    
    is( $form->get_field('id')->default, '4' );
    is( $form->get_field('name')->default, 'nick' );
    is( $form->get_field('count')->default, '2' );
    
    my $block = $form->get_all_element({ nested_name => 'addresses' });
    
    my @reps = @{ $block->get_elements };
    
    is( scalar @reps, 2 );
    
    is( $reps[0]->get_field('id_1')->default, '2' );
    is( $reps[0]->get_field('address_1')->default, 'home' );
    
    is( $reps[1]->get_field('id_2')->default, '3' );
    is( $reps[1]->get_field('address_2')->default, 'office' );
}

