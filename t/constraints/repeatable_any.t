use strict;
use warnings;

use Test::More tests => 10;

use HTML::FormFu;
use lib 't/lib';
use HTMLFormFu::TestLib;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t/constraints/repeatable_any.yml');

$form->get_element( { type => 'Repeatable' } )->repeat(2);

# Valid
{
    $form->process( {
            foo_1 => 'a',
            foo_2 => 'b',
            count => 2,
        } );

    ok( $form->submitted_and_valid );

    is_deeply(
        $form->params,
        {   foo_1 => 'a',
            foo_2 => 'b',
            count => 2,
        } );
}

# Valid - 1 missing
{
    $form->process( {
            foo_1 => 'a',
            foo_2 => '',
            count => 2,
        } );

    ok( $form->submitted_and_valid );

    is_deeply(
        $form->params,
        {   foo_1 => 'a',
            foo_2 => '',
            count => 2,
        } );
}

# Valid - 1 missing
{
    $form->process( {
            foo_1 => '',
            foo_2 => 'b',
            count => 2,
        } );

    ok( $form->submitted_and_valid );

    is_deeply(
        $form->params,
        {   foo_1 => '',
            foo_2 => 'b',
            count => 2,
        } );
}

# Missing - Invalid
{
    $form->process( {
            foo_1 => '',
            foo_2 => '',
            count => 2,
        } );

    ok( !$form->submitted_and_valid );

    # error is only attached to first rep

    is_deeply( [ $form->has_errors ], ['foo_1'] );

    like( $form->get_field( { nested_name => 'foo_1' } ), qr/is required/ );
    unlike( $form->get_field( { nested_name => 'foo_2' } ), qr/is required/ );
}

