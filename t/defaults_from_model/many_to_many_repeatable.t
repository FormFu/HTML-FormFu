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

$form->load_config_file('t/defaults_from_model/many_to_many_repeatable.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $user_rs = $schema->resultset('User');
my $band_rs = $schema->resultset('Band');


{
    # insert some entries we'll ignore, so our rels don't have same ids
    # user 1
    my $u1 = $user_rs->new_result({ name => 'foo' });
    $u1->insert;
    # band 1
    my $b1 = $band_rs->new_result({ band => 'a' });
    $b1->insert;
    $u1->add_to_bands($b1);
    
    # should get user id 2
    my $u2 = $user_rs->new_result({
        name => 'nick',
        });
    $u2->insert;
    
    # should get band id 2
    my $b2 = $band_rs->new_result({ band => 'b' });
    $b2->insert;
    $u2->add_to_bands($b2);
    
    # should get band id 3
    my $b3 = $band_rs->new_result({ band => 'c' });
    $b3->insert;
    $u2->add_to_bands($b3);
    
    # should get band id 4
    my $b4 = $band_rs->new_result({ band => 'd' });
    $b4->insert;
    $u2->add_to_bands($b4);
}

{
    my $row = $user_rs->find(2);
    
    $form->defaults_from_model( $row );
    
    is( $form->get_field('id')->default, '2' );
    is( $form->get_field('name')->default, 'nick' );
    is( $form->get_field('count')->default, '3' );
    
    my $block = $form->get_all_element({ nested_name => 'bands' });
    
    my @reps = @{ $block->get_elements };
    
    is( scalar @reps, 3 );
    
    is( $reps[0]->get_field('id_1')->default, '2' );
    is( $reps[0]->get_field('band_1')->default, 'b' );
    
    is( $reps[1]->get_field('id_2')->default, '3' );
    is( $reps[1]->get_field('band_2')->default, 'c' );
    
    is( $reps[2]->get_field('id_3')->default, '4' );
    is( $reps[2]->get_field('band_3')->default, 'd' );
}

