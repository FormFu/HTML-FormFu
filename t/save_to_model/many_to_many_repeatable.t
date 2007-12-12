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

$form->load_config_file('t/save_to_model/many_to_many_repeatable.yml');

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
    $form->process({
        'id'    => 2,
        'name'  => 'new nick',
        'count' => 2,
        'bands.id_1'      => 2,
        'bands.band_1' => 'b++',
        'bands.id_2'      => 3,
        'bands.band_2' => 'c++',
    });
    
    ok( $form->submitted_and_valid );
    
    my $row = $user_rs->find(2);
    
    $form->save_to_model( $row );
    
    my $user = $user_rs->find(2);
    
    is( $user->name, 'new nick' );
    
    my @add = $user->bands->all;
    
    is( scalar @add, 3 );
    
    is( $add[0]->id, 2 );
    is( $add[0]->band, 'b++' );
    
    is( $add[1]->id, 3 );
    is( $add[1]->band, 'c++' );
    
    # band 4 should be unchanged
    
    is( $add[2]->id, 4 );
    is( $add[2]->band, 'd' );
}

