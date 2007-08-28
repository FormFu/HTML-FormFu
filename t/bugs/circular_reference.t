use strict;
use warnings;

use Test::More;
use HTML::FormFu;

eval "use Test::Memory::Cycle";

if ($@) {
    plan skip_all =>
        'Test::Memory::Cycle required for testing circular references';
    exit;
}

plan( tests => 2 );

my $form = HTML::FormFu->new;

$form->load_config_file('t/bugs/circular_reference.yml');

memory_cycle_ok($form);

memory_cycle_ok( $form->render );
