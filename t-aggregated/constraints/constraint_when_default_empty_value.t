use strict;
use warnings;

use Test::More tests => 8;
use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t-aggregated/constraints/constraint_when_default_empty_value.yml');

# valid - foo Checkbox missing - bar is required
{
    $form->process({
        bar => '42',
    });
    
    ok( $form->submitted_and_valid );
    
    is( $form->param_value('bar'), 42 );
}

# valid - foo Checkbox present - bar optional
{
    $form->process({
        foo => '1',
    });
    
    ok( $form->submitted_and_valid );
    
    is( $form->param_value('foo'), 1 );
}

# valid - foo Checkbox present - bar optional
{
    $form->process({
        foo => '1',
        bar => '42',
    });
    
    ok( $form->submitted_and_valid );
    
    is( $form->param_value('foo'), 1 );
    is( $form->param_value('bar'), 42 );
}

# invalid - foo Checkbox missing - bar required
{
    $form->process({
        bar => '',
    });
    
    ok( !$form->submitted_and_valid );
}
