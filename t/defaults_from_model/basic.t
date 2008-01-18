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

plan tests => 25;

use HTML::FormFu;
use lib 't/lib';
use DBICTestLib 'new_db';
use MySchema;

new_db();

my $form = HTML::FormFu->new;

$form->load_config_file('t/defaults_from_model/basic.yml');

my $schema = MySchema->connect('dbi:SQLite:dbname=t/test.db');

my $rs = $schema->resultset('Master');

# filler row

$rs->create({
    text_col => 'filler',
});

# row we're going to use

$rs->create({
    text_col       => 'a',
    password_col   => 'b',
    checkbox_col   => 'foo',
    select_col     => '2',
    radio_col      => 'yes',
    radiogroup_col => '3',
    date_col       => '2006-12-31 00:00:00'
});

{
    my $row = $rs->find(2);
    
    $form->defaults_from_model( $row );
    
    my $fs = $form->get_element;
    
    is( $fs->get_field('id')->render_data->{value}, 2 );
    is( $fs->get_field('text_col')->render_data->{value}, 'a');
    is( $fs->get_field('password_col')->render_data->{value}, undef);
    
    my $checkbox = $fs->get_field('checkbox_col')->render_data;
    
    is( $checkbox->{value}, 'foo' );
    is( $checkbox->{attributes}{checked}, 'checked' );
    
    # accessing undocumented HTML::FormFu internals below
    # may break in the future
    
    my $select = $fs->get_field('select_col')->render_data;
    
    is( $select->{options}[0]{value}, 1 );
    ok( !exists $select->{options}[0]{attributes}{selected} );
    
    is( $select->{options}[1]{value}, 2 );
    is( $select->{options}[1]{attributes}{selected}, 'selected' );
    
    is( $select->{options}[2]{value}, 3 );
    ok( !exists $select->{options}[2]{attributes}{selected} );
    
    my @radio = map { $_->render_data } @{ $form->get_fields('radio_col') };
    
    is( $radio[0]->{value}, 'yes' );
    is( $radio[0]->{attributes}{checked}, 'checked' );
    
    is( $radio[1]->{value}, 'no' );
    ok( !exists $radio[1]->{attributes}{checked} );
    
    my @rg_option = @{ $fs->get_field('radiogroup_col')->render_data->{options} };
    
    is( $rg_option[0]->{value}, 1 );
    ok( !exists $rg_option[0]->{attributes}{checked} );
    
    is( $rg_option[1]->{value}, 2 );
    ok( !exists $rg_option[1]->{attributes}{checked} );
    
    is( $rg_option[2]->{value}, 3 );
    is( $rg_option[2]->{attributes}{checked}, 'checked' );
    
    # column is inflated
    my $date = $fs->get_field('date_col')->default;
    
    isa_ok( $date, 'DateTime' );
    
    is( $date->day, '31' );
    is( $date->month, '12' );
    is( $date->year, '2006' );
}

