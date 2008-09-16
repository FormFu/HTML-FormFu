use strict;
use warnings;
use Test::More tests => 6;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t-aggregated/elements/combobox_required.yml');

# valid select value
{
    $form->process({
        combo_select => 'one',
        combo_text   => '',
    });
    
    ok( $form->submitted_and_valid );
    
    is( $form->param_value('combo'), 'one' );
}

# valid text value
{
    $form->process({
        combo_select => '',
        combo_text   => 'four',
    });
    
    ok( $form->submitted_and_valid );
    
    is( $form->param_value('combo'), 'four' );
}

# invalid
{
    $form->process({
        combo_select => '',
        combo_text   => '',
        submit       => 'Submit Value',
    });
    
    ok( !$form->submitted_and_valid );
    
    ok( $form->has_errors('combo') );
}
