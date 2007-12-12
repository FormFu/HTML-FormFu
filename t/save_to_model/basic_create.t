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

$form->load_config_file('t/save_to_model/basic.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $rs = $schema->resultset('Master');

# Fake submitted form
$form->process({
    id             => 1,
    text_col       => 'a',
    password_col   => 'b',
    checkbox_col   => 'foo',
    select_col     => '2',
    radio_col      => 'yes',
    radiogroup_col => '3',
    });

{
    my $row = $rs->new({});
    
    $form->save_to_model( $row );
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

