use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->config_file_path('t-aggregated/config_file_path');

$form->load_config_file('form.yml');

ok( $form->get_field('found-me') );
