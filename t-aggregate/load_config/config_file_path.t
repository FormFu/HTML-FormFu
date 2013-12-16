use strict;
use warnings;

use Test::More tests => 4;

use File::Temp qw(tempdir);
use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->config_file_path('t-aggregate/load_config/config_file_path');

$form->load_config_file('form.yml');

ok( $form->get_field('found-me') );

my $form2 = HTML::FormFu->new;

# create dummy temp directories
my @dirs = (
    tempdir( CLEANUP => 1 ),
    tempdir( CLEANUP => 1 ),
    tempdir( CLEANUP => 1 ),
    tempdir( CLEANUP => 1 ),
);
$form2->config_file_path( \@dirs );

eval { $form2->load_config_file('form.yml'); };
ok( $@, "Should die if form.yml is not found" );

$form2->config_file_path( [ @dirs, 't-aggregate/load_config/config_file_path' ] );

$form2->load_config_file('form.yml');
ok( $form2->get_field('found-me') );

my $form3 = HTML::FormFu->new;
$form3->config_file_path( [
        't-aggregate/load_config/config_file_path2', @dirs,
        't-aggregate/load_config/config_file_path'
    ] );
$form3->load_config_file('form.yml');
ok( $form3->get_field('new-found-me') );

