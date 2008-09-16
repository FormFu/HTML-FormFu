use strict;
use warnings;
use Test::More tests => 9;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t-aggregated/elements/combobox.yml');

{
    $form->process;

    is(
        $form->get_element({ type => 'ComboBox' }),
        qq{<div class="combobox">
<span class="elements">
<select name="combo_select">
<option value=""></option>
<option value="one">One</option>
<option value="two">Two</option>
<option value="three">Three</option>
</select>
<input name="combo_text" type="text" />
</span>
</div>}
    );
}

{
    $form->get_element({ type => 'ComboBox' })->default('one');
    $form->process;

    is(
        $form->get_element({ type => 'ComboBox' }),
        qq{<div class="combobox">
<span class="elements">
<select name="combo_select">
<option value=""></option>
<option value="one" selected="selected">One</option>
<option value="two">Two</option>
<option value="three">Three</option>
</select>
<input name="combo_text" type="text" />
</span>
</div>}
    );
}

{
    $form->get_element({ type => 'ComboBox' })->default('four');
    $form->process;

    is(
        $form->get_element({ type => 'ComboBox' }),
        qq{<div class="combobox">
<span class="elements">
<select name="combo_select">
<option value=""></option>
<option value="one">One</option>
<option value="two">Two</option>
<option value="three">Three</option>
</select>
<input name="combo_text" type="text" value="four" />
</span>
</div>}
    );
}

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

# valid - text is used in preference to select value
{
    $form->process({
        combo_select => 'one',
        combo_text   => 'four',
    });
    
    ok( $form->submitted_and_valid );
    
    is( $form->param_value('combo'), 'four' );
}
