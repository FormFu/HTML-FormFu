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

plan tests => 16;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/defaults_from_model/many_to_many_repeatable_nested.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $rs = $schema->resultset('User');

# filler

{
    my $user = $rs->create({
        name => 'filler',
    });
    
    $user->add_to_bands({
        band => 'a',
    });
    
    $rs->create({
        name => 'filler2',
    });
    
    $rs->create({
        name => 'filler3',
    });
    
    $rs->create({
        name => 'filler4',
    });
}

# row we're going to use

{
    my $user = $rs->create({
        name => 'nick',
    });
    
    $user->add_to_bands({
        band => 'b',
    });
    
    $user->add_to_bands({
        band => 'c',
    });
    
    $user->add_to_bands({
        band => 'd',
    });
}

{
    my $row = $rs->find(5);
    
    $form->defaults_from_model( $row, { nested_base => 'foo' } );
    
    is( $form->get_field({ nested_name => 'foo.id' })->default, '5' );
    is( $form->get_field({ nested_name => 'foo.name' })->default, 'nick' );
    is( $form->get_field({ nested_name => 'foo.count' })->default, '3' );
    
    my $block = $form->get_all_element({ nested_name => 'bands' });
    
    my @reps = @{ $block->get_elements };
    
    is( scalar @reps, 3 );
    
    is( $reps[0]->get_field('id_1')->default, '2' );
    is( $reps[0]->get_field('band_1')->default, 'b' );
    
    is( $reps[1]->get_field('id_2')->default, '3' );
    is( $reps[1]->get_field('band_2')->default, 'c' );
    
    is( $reps[2]->get_field('id_3')->default, '4' );
    is( $reps[2]->get_field('band_3')->default, 'd' );
    
    # check the same values from the form, not the block
    
    is( $form->get_field({ nested_name => 'foo.bands.id_1' })->default, '2' );
    is( $form->get_field({ nested_name => 'foo.bands.band_1' })->default, 'b' );
    
    is( $form->get_field({ nested_name => 'foo.bands.id_2' })->default, '3' );
    is( $form->get_field({ nested_name => 'foo.bands.band_2' })->default, 'c' );
    
    is( $form->get_field({ nested_name => 'foo.bands.id_3' })->default, '4' );
    is( $form->get_field({ nested_name => 'foo.bands.band_3' })->default, 'd' );
}

