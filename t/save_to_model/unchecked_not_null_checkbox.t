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

plan tests => 1;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/save_to_model/basic.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $rs = $schema->resultset('Master');

{
    my $row = $rs->new_result({
        checkbox_col => 'xyzfoo',
        });
    
    $row->insert;
}

# an unchecked Checkbox causes no key/value to be submitted at all
# this is a problem for NOT NULL columns
# ensure the column's default value gets inserted

$form->process({
    id => 1,
    });

{
    my $row = $rs->find(1);
    
    $form->save_to_model($row);
}

{
    my $row = $rs->find(1);
    
    is( $row->checkbox_col, '0' );
}

