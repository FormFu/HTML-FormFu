use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;
use lib 't/lib';
use HTMLFormFu::TestLib;

my $form = HTML::FormFu->new;

$form->load_config_file('t/repeatable/repeatable/constraints/repeatable_any.yml');

# Valid
{
    $form->process( {
            outer_count   => 3,
            foo_1         => 'a',
            foo_2         => '',
            foo_3         => '',
            inner_count_1 => 2,
            foo_1_1       => '',
            foo_1_2       => 'b',
            inner_count_2 => 3,
            foo_2_1       => '',
            foo_2_2       => '',
            foo_2_3       => 'c',
            inner_count_3 => 1,
            foo_3_1       => 'd',
        } );

    ok( $form->submitted_and_valid );
}

# Missing - Invalid
{
    $form->process( {
            outer_count   => 3,
            foo_1         => '',
            foo_2         => '',
            foo_3         => '',
            inner_count_1 => 2,
            foo_1_1       => '',
            foo_1_2       => 'b',
            inner_count_2 => 3,
            foo_2_1       => '',
            foo_2_2       => '',
            foo_2_3       => 'c',
            inner_count_3 => 1,
            foo_3_1       => '',
        } );

    ok( !$form->submitted_and_valid );

    # error is only attached to first rep

    is_deeply(
        [ $form->has_errors ],
        ['foo_1', 'foo_3_1']
    );
}

