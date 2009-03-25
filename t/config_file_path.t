use strict;
use warnings;

use Test::More tests => 2;

use File::Temp qw(tempdir);
use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->config_file_path('t/config_file_path');

$form->load_config_file('form.yml');

ok( $form->get_field('found-me') );

my $form2 = HTML::FormFu->new;

# create dummy temp directories
my @dirs = (
    tempdir(CLEANUP => 1),
    tempdir(CLEANUP => 1),
    't/config_file_path',
    tempdir(CLEANUP => 1),
    tempdir(CLEANUP => 1),
);
$form2->config_file_path(\@dirs);

$form2->load_config_file('form.yml');

ok( $form2->get_field('found-me') );

