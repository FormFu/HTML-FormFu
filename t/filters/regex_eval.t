use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t/filters/regex_eval.yml');

{
    $form->process({
        foo => '.4.5 ',
    });
    
    is( $form->param_value('foo'), '4.5' );
}

{
    $form->process({
        foo => '4.',
    });
    
    is( $form->param_value('foo'), '4' );
}

{
    $form->process({
        foo => '4.0',
    });
    
    is( $form->param_value('foo'), '4.0' );
}

# doesn't filter, as it doesn't match the regex
{
    $form->process({
        foo => ' a',
    });
    
    is( $form->param_value('foo'), ' a' );
}
