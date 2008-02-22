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

plan tests => 5;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;
new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/options_from_model/condition_from_stash.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

$form->stash->{schema} = $schema;

my $master_rs = $schema->resultset('Master');
my $user_rs   = $schema->resultset('User');

{
    my $m1 = $master_rs->create({ text_col => 'foo' });
    
    $m1->create_related( 'user', { name => 'a' } );
    $m1->create_related( 'user', { name => 'b' } );
    $m1->create_related( 'user', { name => 'c' } );
}

{
    my $m2 = $master_rs->create({ text_col => 'foo' });
    
    $m2->create_related( 'user', { name => 'd' } );
    $m2->create_related( 'user', { name => 'e' } );
    $m2->create_related( 'user', { name => 'f' } );
    $m2->create_related( 'user', { name => 'g' } );
    
    $form->stash->{master_id} = $m2->id;
}

$form->process;

{
    my $option = $form->get_field('user')->options;
    
    ok( @$option == 4 );
    
    is( $option->[0]->{label}, 'd' );
    is( $option->[1]->{label}, 'e' );
    is( $option->[2]->{label}, 'f' );
    is( $option->[3]->{label}, 'g' );
}
