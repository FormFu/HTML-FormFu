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

$form->load_config_file('t/save_to_model/column_without_field.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $rs = $schema->resultset('Master');

{
    my $row = $rs->new_result({
        text_col     => 'a',
        password_col => 'd',
        checkbox_col => 'g'
        });
    
    $row->insert;
}

# Fake submitted form
$form->process({
    id       => 1,
    text_col => 'abc',
    });

{
    my $row = $rs->find(1);
    
    $form->save_to_model( $row );
}

{
    my $row = $rs->find(1);
    
    is( $row->text_col, 'abc' );
    
    # original values still there
    
    is( $row->password_col, 'd' );
    is( $row->checkbox_col, 'g' );
}

