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

plan tests => 2;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/defaults_from_model/belongs_to_lookup_table.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $rs = $schema->resultset('Master');

# Fake submitted form
$form->process( {
        "id"       => 3,
        "text_col" => 'a',
        'type'     => '1',
        'type2_id' => '1',
    } );

my $master;
{

    # insert some entries we'll ignore, so our rels don't have same ids
    # test id 1
    my $t1 = $rs->create( { text_col => 'xxx' } );

    # test id 2
    my $t2 = $rs->create( { text_col => 'yyy' } );

    # should get master id 3
    $master = $rs->create( { text_col => 'b', type => 2, type2_id => 2 } );

    $form->model('DBIC')->save($master);
}

{
    my $row = $rs->find( $master->id );

    is( $row->type->id, '1' );
    is( $row->type2_id, '1' );

}

