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

plan tests => 3;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/save_to_model/opt_accessor.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $rs = $schema->resultset('User');

# filler row

$rs->create({
    name => 'foo',
});

# Fake submitted form
$form->process({
    id       => 2,
    fullname => 'mr billy bob',
    });

{
    my $row = $rs->new({});
    
    $form->save_to_model( $row );
}

{
    my $row = $rs->find(2);
    
    is( $row->title,    'mr' );
    is( $row->name,     'billy bob' );
    is( $row->fullname, 'mr billy bob' );
}

