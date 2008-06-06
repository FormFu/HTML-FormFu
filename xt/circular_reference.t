use strict;
use warnings;

use Test::More tests => 2;
use Test::Memory::Cycle;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('xt/circular_reference.yml');

memory_cycle_ok($form);

memory_cycle_ok( $form->render );
