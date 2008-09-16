use strict;
use warnings;

use Test::More tests => 7;

use HTML::FormFu;
use lib 't/lib';
use HTMLFormFu::TestLib;

my $form = HTML::FormFu->new;

$form->load_config_file('t-aggregated/repeatable/constraints/required.yml');

$form->get_element( { type => 'Repeatable' } )->repeat(2);

# Valid
{
    $form->process( {
            'rep.foo_1' => 'a',
            'rep.bar_1' => 'b',
            'rep.foo_2' => 'c',
            'rep.bar_2' => 'd',
            count       => 2,
        } );

    ok( $form->submitted_and_valid );

    is_deeply(
        $form->params,
        {   rep => {
                foo_1 => 'a',
                bar_1 => 'b',
                foo_2 => 'c',
                bar_2 => 'd',
            },
            count => 2,
        } );
}

# Missing - Invalid
{
    $form->process( {
            'rep.bar_1' => 'b',
            'rep.foo_2' => 'c',
            count       => 2,
        } );

    ok( !$form->submitted_and_valid );

    ok( $form->has_errors('rep.foo_1') );
    ok( !$form->has_errors('rep.bar_1') );
    ok( !$form->has_errors('rep.foo_2') );
    ok( $form->has_errors('rep.bar_2') );
}

