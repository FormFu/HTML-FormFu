use strict;
use warnings;
use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t/elements/combo_box.yml');

# valid
{
    $form->process({
        foo => 'one',
    });
    
    ok( $form->submitted_and_valid );
    
    is( $form->param_value('foo'), 'one' );
}

# invalid
{
    $form->process({
        foo => ['one', 'two'],
    });
    
    ok( ! $form->submitted_and_valid );
}
