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

# filler row

$rs->create({
    text_col => 'filler',
});

# row we're going to use

$rs->create({
    text_col => 'a',
    type     => 3,
});

{
    my $row = $rs->find(2);
    
    $form->defaults_from_model($row);
    
    is( $form->get_field('id')->render_data->{value}, 2 );
    
    is( $form->get_field('type')->render_data->{value}, 3 );
}

