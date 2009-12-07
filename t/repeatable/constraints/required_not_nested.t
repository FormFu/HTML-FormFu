use strict;
use warnings;

use Test::More tests => 11;

use HTML::FormFu;
use lib 't/lib';
use HTMLFormFu::TestLib;

my $form = HTML::FormFu->new;

$form->load_config_file('t/repeatable/constraints/required_not_nested.yml');

$form->get_element( { type => 'Repeatable' } )->repeat(2);

# Valid
{
    $form->process( {
            foo_1 => 'a',
            bar_1 => 'b',
            foo_2 => 'c',
            bar_2 => 'd',
            count => 2,
        } );

    ok( $form->submitted_and_valid );

    is_deeply(
        $form->params,
        {
            foo_1 => 'a',
            bar_1 => 'b',
            foo_2 => 'c',
            bar_2 => 'd',
            count => 2,
        } );
}

# Missing - Invalid
{
    $form->process( {
            bar_1 => 'b',
            foo_2 => 'c',
            count => 2,
        } );

    ok( !$form->submitted_and_valid );

    ok( $form->has_errors('foo_1') );
    ok( !$form->has_errors('bar_1') );
    ok( !$form->has_errors('foo_2') );
    ok( $form->has_errors('bar_2') );

    like( $form->get_field( 'foo_1' ), qr/error/ );
    unlike( $form->get_field( 'bar_1' ), qr/error/ );
    unlike( $form->get_field( 'foo_2' ), qr/error/ );
    like( $form->get_field( 'bar_2' ), qr/error/ );
}

