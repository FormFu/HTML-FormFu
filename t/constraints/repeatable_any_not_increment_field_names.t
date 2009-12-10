use strict;
use warnings;

use Test::More 'no_plan';#tests => 10;

use HTML::FormFu;
use lib 't/lib';
use HTMLFormFu::TestLib;

my $form = HTML::FormFu->new;

$form->load_config_file('t/constraints/repeatable_any_not_increment_field_names.yml');

# Valid
{
    $form->process( {
            foo   => ['a', 'b'],
            count => 2,
        } );

    ok( $form->submitted_and_valid );

    is_deeply(
        $form->params,
        {   
            foo => ['a', 'b'],
            count => 2,
        } );
    
    is_deeply(
        [ $form->has_errors ],
        []
    );
}

# Valid - 1 missing
{
    $form->process( {
            foo   => ['a', ''],
            count => 2,
        } );

    ok( $form->submitted_and_valid );

    is_deeply(
        $form->params,
        {   
            foo   => ['a', ''],
            count => 2,
        } );
    
    is_deeply(
        [ $form->has_errors ],
        []
    );
}

# Valid - 1 missing
{
    $form->process( {
            foo   => ['', 'b'],
            count => 2,
        } );

    ok( $form->submitted_and_valid );

    is_deeply(
        $form->params,
        {   
            foo   => ['', 'b'],
            count => 2,
        } );
    
    is_deeply(
        [ $form->has_errors ],
        []
    );
}

# Missing - Invalid
{
    $form->process( {
            foo   => ['', ''],
            count => 2,
        } );

    ok( !$form->submitted_and_valid );

    is_deeply(
        [ $form->has_errors ],
        ['foo']
    );
}

