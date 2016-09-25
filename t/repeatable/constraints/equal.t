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
            'rep_1.foo' => 'a',
            'rep_1.bar' => 'a',
            'rep_1.baz' => 'a',
            'rep_2.foo' => 'c',
            'rep_2.bar' => 'c',
            'rep_2.baz' => 'c',
            count       => 2,
        } );

    ok( $form->submitted_and_valid );

    is_deeply(
        $form->params,
        {   rep_1 => {
                foo => 'a',
                bar => 'a',
                baz => 'a',
            },
            rep_2 => {
                foo => 'c',
                bar => 'c',
                baz => 'c',
            },
            count => 2,
        } );
}

# Invalid
{
    $form->process( {
            'rep_1.foo' => 'a',
            'rep_1.bar' => 'a',
            'rep_1.baz' => 'a',
            'rep_2.foo' => 'c',
            'rep_2.bar' => 'd',
            'rep_2.baz' => 'c',
            count       => 2,
        } );

    ok( !$form->submitted_and_valid );

    ok( !$form->has_errors('rep_1.foo') );
    ok( !$form->has_errors('rep_1.bar') );
    ok( !$form->has_errors('rep_1.baz') );
    ok( !$form->has_errors('rep_2.foo') );
    ok( $form->has_errors('rep_2.bar') );
    ok( !$form->has_errors('rep_2.baz') );
}

# Missing - Invalid
{
    $form->process( {
            'rep_1.foo' => 'a',
            'rep_1.bar' => 'a',
            'rep_1.baz' => 'a',
            'rep_2.foo' => 'c',
            count       => 2,
        } );

    ok( !$form->submitted_and_valid );

    ok( !$form->has_errors('rep_1.foo') );
    ok( !$form->has_errors('rep_1.bar') );
    ok( !$form->has_errors('rep_1.baz') );
    ok( !$form->has_errors('rep_2.foo') );
    ok( $form->has_errors('rep_2.bar') );
    ok( $form->has_errors('rep_2.baz') );
}

