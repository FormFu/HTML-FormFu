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

plan tests => 7;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();


my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $rs = $schema->resultset('Master');
{
    my $form = HTML::FormFu->new;

    $form->load_config_file('t/save_to_model/methods.yml');
    # Fake submitted form
    $form->process( {
            method_test => 'apejens',
            method_checkbox_test => 1,
        } );

    {
        my $row = $rs->new( {} );

        $form->model('DBIC')->save($row);
    }

    {
        my $row = $rs->find(1);

        is( $row->text_col,             'apejens' );
        is( $row->method_test,          'apejens' );
        is( $row->checkbox_col,         1);
        is( $row->method_checkbox_test, 1);
    }

    }
{
    my $form = HTML::FormFu->new;

    $form->load_config_file('t/save_to_model/methods.yml');
    
    $form->process({
        method_test => 'apejens2',
    });
    my $row = $rs->find(1);
    $form->model('DBIC')->save($row);
    
    is( $row->text_col,                 'apejens2' );
    is( $row->checkbox_col,             0);
    is( $row->method_checkbox_test,     0);
}
