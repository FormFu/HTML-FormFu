use strict;
use warnings;

use Test::More tests => 16;

use HTML::FormFu;
use lib 't/lib';
use HTMLFormFu::TestLib;

my $form = HTML::FormFu->new;

$form->load_config_file('t/repeatable/constraints/equal.yml');

$form->get_element( { type => 'Repeatable' } )->repeat(2);

# Valid
{
    $form->process( {
            'rep.foo_1' => 'a',
            'rep.bar_1' => 'a',
            'rep.baz_1' => 'a',
            'rep.foo_2' => 'c',
            'rep.bar_2' => 'c',
            'rep.baz_2' => 'c',
            count       => 2,
        } );

    ok( $form->submitted_and_valid );

    is_deeply(
        $form->params,
        {   rep => {
                foo_1 => 'a',
                bar_1 => 'a',
                baz_1 => 'a',
                foo_2 => 'c',
                bar_2 => 'c',
                baz_2 => 'c',
            },
            count => 2,
        } );
}

# Invalid
{
    $form->process( {
            'rep.foo_1' => 'a',
            'rep.bar_1' => 'a',
            'rep.baz_1' => 'a',
            'rep.foo_2' => 'c',
            'rep.bar_2' => 'd',
            'rep.baz_2' => 'c',
            count       => 2,
        } );

    ok( !$form->submitted_and_valid );

    ok( !$form->has_errors('rep.foo_1') );
    ok( !$form->has_errors('rep.bar_1') );
    ok( !$form->has_errors('rep.baz_1') );
    ok( !$form->has_errors('rep.foo_2') );
    ok( $form->has_errors('rep.bar_2') );
    ok( !$form->has_errors('rep.baz_2') );
}

# Missing - Invalid
{
    $form->process( {
            'rep.foo_1' => 'a',
            'rep.bar_1' => 'a',
            'rep.baz_1' => 'a',
            'rep.foo_2' => 'c',
            count       => 2,
        } );

    ok( !$form->submitted_and_valid );

    ok( !$form->has_errors('rep.foo_1') );
    ok( !$form->has_errors('rep.bar_1') );
    ok( !$form->has_errors('rep.baz_1') );
    ok( !$form->has_errors('rep.foo_2') );
    ok( $form->has_errors('rep.bar_2') );
    ok( $form->has_errors('rep.baz_2') );
}

