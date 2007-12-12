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

plan tests => 6;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/save_to_model/nested.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $rs = $schema->resultset('Master');

# Fake submitted form
$form->process({
    "foo.id"             => 1,
    "foo.text_col"       => 'a',
    "foo.password_col"   => 'b',
    "foo.checkbox_col"   => 'foo',
    "foo.select_col"     => '2',
    "foo.radio_col"      => 'yes',
    "foo.radiogroup_col" => '3',
    });

{
    my $row = $rs->new({});
    
    $form->save_to_model( $row, { nested_base => 'foo' } );
}

{
    my $row = $rs->find(1);
    
    is( $row->text_col,       'a' );
    is( $row->password_col,   'b');
    is( $row->checkbox_col,   'foo' );
    is( $row->select_col,     '2' );
    is( $row->radio_col,      'yes' );
    is( $row->radiogroup_col, '3' )
}

