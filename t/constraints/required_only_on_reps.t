use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;
use lib 't/lib';
use HTMLFormFu::TestLib;

my $form = HTML::FormFu->new;

$form->load_config_file('t/constraints/required_only_on_reps.yml');

# Valid
{
    $form->process( {
            foo_1 => 'a',
            bar_1 => '',
            buz_1 => 'g',
            moo_1 => 'j',
            foo_2 => '',
            bar_2 => 'e',
            buz_2 => '',
            moo_2 => 'k',
            foo_3 => '',
            bar_3 => '',
            buz_3 => 'i',
            moo_3 => 'l',
            count => 3,
        } );

    ok( $form->submitted_and_valid );
}

# Valid
{
    $form->process( {
            foo_1 => 'a',
            bar_1 => 'd',
            buz_1 => 'g',
            moo_1 => 'j',
            foo_2 => 'b',
            bar_2 => 'e',
            buz_2 => 'h',
            moo_2 => 'k',
            foo_3 => 'c',
            bar_3 => 'f',
            buz_3 => 'i',
            moo_3 => 'l',
            count => 3,
        } );

    ok( $form->submitted_and_valid );
}

# Missing - Invalid
{
    $form->process( {
            foo_1 => '',
            bar_1 => '',
            buz_1 => '',
            moo_1 => '',
            foo_2 => '',
            bar_2 => '',
            buz_2 => '',
            moo_2 => 'k',
            foo_3 => '',
            bar_3 => '',
            buz_3 => 'i',
            moo_3 => '',
            count => 3,
        } );

    ok( ! $form->submitted_and_valid );

    is_deeply(
        [ $form->has_errors ],
        [qw/
            foo_1
            buz_1
            moo_1
            bar_2
            moo_3
        /]
    );
}
