use strict;
use warnings;

use Test::More 'no_plan';

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t/constraints/constraint_when_fields.yml');

# Valid
{
    $form->process( {
            a => '',
            b => '',
            c => '',
        } );

    ok( $form->submitted_and_valid );

    ok( $form->valid('a'), 'a valid' );
    ok( $form->valid('b'), 'b valid' );
    ok( $form->valid('c'), 'c valid' );
}

# Valid
{
    $form->process( {
            a => '1',
            b => '',
            c => '',
        } );

    ok( $form->submitted_and_valid );

    ok( $form->valid('a'), 'a valid' );
    ok( $form->valid('b'), 'b valid' );
    ok( $form->valid('c'), 'c valid' );
}

# Valid
{
    # Bool constraint doesn't run because b & c don't both have values
    
    $form->process( {
            a => 'a',
            b => '',
            c => '',
        } );

    ok( $form->submitted_and_valid );

    ok( $form->valid('a'), 'a valid' );
    ok( $form->valid('b'), 'b valid' );
    ok( $form->valid('c'), 'c valid' );
}

# Valid
{
    # Bool constraint doesn't run because b & c don't both have values
    
    $form->process( {
            a => 'a',
            b => '',
            c => '1',
        } );

    ok( $form->submitted_and_valid );

    ok( $form->valid('a'), 'a valid' );
    ok( $form->valid('b'), 'b valid' );
    ok( $form->valid('c'), 'c valid' );
}

# Valid
{
    $form->process( {
            a => '1',
            b => '1',
            c => '1',
        } );

    ok( $form->submitted_and_valid );

    ok( $form->valid('a'), 'a valid' );
    ok( $form->valid('b'), 'b valid' );
    ok( $form->valid('c'), 'c valid' );
}

# Valid
{
    # Empty is valid

    $form->process( {
            a => '',
            b => '1',
            c => '1',
        } );

    ok( $form->submitted_and_valid );

    ok( $form->valid('a'), 'a valid' );
    ok( $form->valid('b'), 'b valid' );
    ok( $form->valid('c'), 'c valid' );
}

# Invalid
{
    $form->process( {
            a => 'a',
            b => '1',
            c => '1',
        } );

    ok( !$form->submitted_and_valid );

    ok( !$form->valid('a'), 'a not valid' );
    ok( $form->valid('b'), 'b valid' );
    ok( $form->valid('c'), 'c valid' );
}
