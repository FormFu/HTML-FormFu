use strict;
use warnings;

use Test::More 'no_plan';

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t/constraints/constraint_when_any_field.yml');

#$ENV{HTML_FORMFU_DEBUG_PROCESS} = 1;

# Valid
{
    $form->process(
        {   a => '',
            b => '',
            c => '',
            d => '',
        } );

    ok( $form->submitted_and_valid );

    ok( $form->valid('a'), 'a valid' );
    ok( $form->valid('b'), 'b valid' );
    ok( $form->valid('c'), 'c valid' );
    ok( $form->valid('d'), 'd valid' );
}

# Valid
{
    $form->process(
        {   a => '1',
            b => '',
            c => '',
            d => '',
        } );

    ok( $form->submitted_and_valid );

    ok( $form->valid('a'), 'a valid' );
    ok( $form->valid('b'), 'b valid' );
    ok( $form->valid('c'), 'c valid' );
    ok( $form->valid('d'), 'd valid' );
}

# Valid
{
    $form->process(
        {   a => '',
            b => '1',
            c => '',
            d => '',
        } );

    ok( $form->submitted_and_valid );

    ok( $form->valid('a'), 'a valid' );
    ok( $form->valid('b'), 'b valid' );
    ok( $form->valid('c'), 'c valid' );
    ok( $form->valid('d'), 'd valid' );
}

# Valid
{
    $form->process(
        {   a => '',
            b => '',
            c => '1',
            d => '',
        } );

    ok( $form->submitted_and_valid );

    ok( $form->valid('a'), 'a valid' );
    ok( $form->valid('b'), 'b valid' );
    ok( $form->valid('c'), 'c valid' );
    ok( $form->valid('d'), 'd valid' );
}

# Valid
{
    $form->process(
        {   a => '',
            b => '',
            c => '',
            d => '1',
        } );

    ok( $form->submitted_and_valid );

    ok( $form->valid('a'), 'a valid' );
    ok( $form->valid('b'), 'b valid' );
    ok( $form->valid('c'), 'c valid' );
    ok( $form->valid('d'), 'd valid' );
}

# Valid
{
    $form->process(
        {   a => '1',
            b => '1',
            c => '',
            d => '',
        } );

    ok( $form->submitted_and_valid );

    ok( $form->valid('a'), 'a valid' );
    ok( $form->valid('b'), 'b valid' );
    ok( $form->valid('c'), 'c valid' );
    ok( $form->valid('d'), 'd valid' );
}

# Valid
{
    $form->process(
        {   a => '',
            b => '1',
            c => '1',
            d => '',
        } );

    ok( $form->submitted_and_valid );

    ok( $form->valid('a'), 'a valid' );
    ok( $form->valid('b'), 'b valid' );
    ok( $form->valid('c'), 'c valid' );
    ok( $form->valid('d'), 'd valid' );
}

# Invalid
{
    $form->process(
        {   a => '1',
            b => '1',
            c => '1',
            d => '',
        } );

    ok( !$form->submitted_and_valid );

    ok( !$form->valid('a'), 'a not valid' );
    ok( $form->valid('b'),  'b valid' );
    ok( $form->valid('c'),  'c valid' );
    ok( $form->valid('d'),  'd valid' );
}

# Invalid
{
    $form->process(
        {   a => '',
            b => '1',
            c => '1',
            d => '1',
        } );

    ok( !$form->submitted_and_valid );

    ok( !$form->valid('a'), 'a not valid' );
    ok( $form->valid('b'),  'b valid' );
    ok( $form->valid('c'),  'c valid' );
    ok( $form->valid('d'),  'd valid' );
}

# Invalid
{
    $form->process(
        {   a => '1',
            b => '1',
            c => '1',
            d => '1',
        } );

    ok( !$form->submitted_and_valid );

    ok( !$form->valid('a'), 'a not valid' );
    ok( $form->valid('b'),  'b valid' );
    ok( $form->valid('c'),  'c valid' );
    ok( $form->valid('d'),  'd valid' );
}
