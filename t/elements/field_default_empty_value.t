use strict;
use warnings;

use Test::More tests => 1;
use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t/elements/field_default_empty_value.yml');

$form->process( {
    f1 => 42,
    # f2 isn't submitted
    'nested.g1' => 99,
    # nested.g2 isn't submitted
    count => 2,
    rep => 2,
    'rep_1.h1' => 21,
    # rep_1.h2 isn't submitted
    # rep_2.h1 isn't submitted
    'rep_2.h2' => 11,
} );

is_deeply(
    $form->params,
    {   f1 => 42,
        f2 => '',
        count => 2,
        nested => {
            g1 => 99,
            g2 => '',
        },
        rep_1 => {
            h1 => 21,
            h2 => '',
        },
        rep_2 => {
            h1 => '',
            h2 => 11,
        },
    } );
