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

$form->load_config_file('t/options_from_model/belongs_to.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

$form->stash->{schema} = $schema;

my $type_rs  = $schema->resultset('Type');
my $type2_rs = $schema->resultset('Type2');

{

    # types
    $type_rs->delete;
    $type_rs->create( { type => 'type 1' } );
    $type_rs->create( { type => 'type 2' } );
    $type_rs->create( { type => 'type 3' } );

    $type2_rs->delete;
    $type2_rs->create( { type => 'type 1' } );
    $type2_rs->create( { type => 'type 2' } );
    $type2_rs->create( { type => 'type 3' } );
}

$form->process;

{
    my $option = $form->get_field('type')->options;
    
    ok( @$option == 3 );
    
    is( $option->[0]->{label}, 'type 1' );
    is( $option->[1]->{label}, 'type 2' );
    is( $option->[2]->{label}, 'type 3' );
}

{
    my $option = $form->get_field('type2_id')->options;
    
    ok( @$option == 3 );
    
    is( $option->[0]->{label}, 'type 1' );
    is( $option->[1]->{label}, 'type 2' );
    is( $option->[2]->{label}, 'type 3' );
}

