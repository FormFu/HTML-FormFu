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

plan tests => 3;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/defaults_from_model/many_to_many_select.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $user_rs = $schema->resultset('User');
my $band_rs = $schema->resultset('Band');

{
    # user 1
    my $u1 = $user_rs->new_result({ name => 'John' });
    $u1->insert;
    # user 2
    my $u2 = $user_rs->new_result({ name => 'Paul' });
    $u2->insert;
    # band 1
    my $b1 = $u1->add_to_bands({ band => 'the beatles' });
    # user 2 => band 2
    $u2->add_to_bands({ band => 'wings' });
    # band 3
    $band_rs->new_result({ band => 'the kinks' });
    # user 2 => band 1
    $u2->add_to_bands( $b1 );
}

{
    my $row = $user_rs->find(2);
    
    $form->defaults_from_model( $row );
    
    is( $form->get_field('id')->default, 2 );
    is( $form->get_field('name')->default, 'Paul' );
    
    is_deeply(
        $form->get_field('bands')->default,
        [1, 2]
    );
}

