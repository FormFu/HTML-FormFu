use strict;
use warnings;
use Test::More tests => 5;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t/elements/combobox_repeatable.yml');

# repeatable
{
    my $container = $form->get_all_element('container');

    $form->process({
        count => 3,
        combo_1_select => 'one',
        combo_2_select => 'two',
        combo_3_select => 'three',
    });

    ok( $form->submitted_and_valid );

    is( $form->param_value('combo_1'), 'one' );
    is( $form->param_value('combo_2'), 'two' );
    is( $form->param_value('combo_3'), 'three' );
    is( $form->param_value('combo_3_select'), 'three' );
}

