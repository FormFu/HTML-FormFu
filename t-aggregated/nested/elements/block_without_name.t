use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t-aggregated/nested/elements/block_without_name.yml');

is( $form->get_field('bar')->nested_name, 'foo.bar' );

