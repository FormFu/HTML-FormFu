use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t/filters/compoundjoin.yml');

$form->process;

$form->process(
    {
        'rep_1.address.number' => '10',
        'rep_1.address.street' => 'Downing Street',
    }
);

ok( $form->submitted_and_valid );

is( $form->param_value('rep_1.address'), '10 Downing Street' );

is_deeply( $form->params, { rep_1 => { address => '10 Downing Street' }, }, );
