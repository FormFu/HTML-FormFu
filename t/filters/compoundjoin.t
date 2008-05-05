use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t/filters/compoundjoin.yml');

$form->process({
    'address.number' => '10',
    'address.street' => 'Downing Street',
});

ok( $form->submitted_and_valid );

is( $form->param_value('address'), '10 Downing Street' );

is_deeply(
    $form->params,
    {
        address => '10 Downing Street',
    },
);
