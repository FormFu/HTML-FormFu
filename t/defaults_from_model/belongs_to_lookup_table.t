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

{
    my $master = $rs->new_result({
        text_col => 'a',
        type     => 2,
        });
    
    $master->insert;
}

{
    my $row = $rs->find(1);;
    
    $form->defaults_from_model($row);
    
    is( $form->get_field('id')->render_data->{value}, 1 );
    
    is( $form->get_field('type')->render_data->{value}, 2 );
}

