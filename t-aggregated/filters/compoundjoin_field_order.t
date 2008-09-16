use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t-aggregated/filters/compoundjoin_field_order.yml');

$form->process({
    'address.street' => 'Downing Street',
    'address.number' => '10',
});

ok( $form->submitted_and_valid );

is( $form->param_value('address'), '10 Downing Street' );
