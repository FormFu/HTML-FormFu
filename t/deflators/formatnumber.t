use strict;
use warnings;

use Test::More tests => 1;
use HTML::FormFu;
use Number::Format;

# This test is pretty hard to write
# you cannot know which locales are installed on a system
# and how the result should look like for every locale
# I simply check here whether the number looks right.

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t/deflators/formatnumber.yml');

$form->get_field('foo')->default('10002300.123');

{
    $form->process;

    like(
        $form->render,
        qr/\"10[,.\h]{0,2}002[,.\h]{0,2}300[.,\h]123[,.\h]?000[,.\h]?00\"/,
        'formatted number is there'
    );
}
