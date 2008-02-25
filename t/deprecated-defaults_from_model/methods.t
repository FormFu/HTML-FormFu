use strict;
use warnings;
use Test::More;

BEGIN {
    eval "use DBIx::Class 0.08002";
    if ($@) {
        plan skip_all => 'DBIx::Class required';
        exit;
    }
    eval "use DateTime::Format::MySQL";
    if ($@) {
        plan skip_all => 'DateTime::Format::MySQL required';
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

$form->load_config_file('t/deprecated-defaults_from_model/methods.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $rs = $schema->resultset('Master');

# filler row

$rs->create( { text_col => 'filler', } );

{
    my $row = $rs->find(1);

    $form->defaults_from_model($row);

    my $field = $form->get_element('method_test');

    is( $field->render_data->{value},           "filler" );
    
}

