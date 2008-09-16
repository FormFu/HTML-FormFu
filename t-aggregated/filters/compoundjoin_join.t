use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t-aggregated/filters/compoundjoin_join.yml');

$form->process({
    'sortcode.p1' => '01',
    'sortcode.p2' => '02',
    'sortcode.p3' => '03',
});

ok( $form->submitted_and_valid );

is( $form->param_value('sortcode'), '01-02-03' );
