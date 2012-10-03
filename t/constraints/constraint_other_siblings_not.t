use strict;
use warnings;

use Test::More tests => 24;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t/constraints/constraint_other_siblings_not.yml');

# Valid
{
    $form->process( {
            foo => 'yada',
            bar => 'boba',
            baz => 'sith',
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
    ok( $form->valid('bar'), 'baz valid' );
}

# Valid
{
    $form->process( {
            foo => '',
            bar => '',
            baz => '',
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
    ok( $form->valid('baz'), 'baz valid' );
}

# Valid
{
    $form->process( {
            foo => '',
            bar => 'yada',
            baz => 'boba',
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
    ok( $form->valid('baz'), 'baz valid' );
}

# Valid
{
    $form->process( {
            foo => 'yada',
            bar => '',
            baz => '',
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
    ok( $form->valid('baz'), 'baz valid' );
}

# Valid
{
    $form->process( {
            foo => '',
            bar => 'yada',
            baz => '',
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
    ok( $form->valid('baz'), 'baz valid' );
}

# Invalid
{
    $form->process( {
            foo => 'yada',
            bar => 'yada',
            baz => 'x',
        } );

    ok( $form->valid('foo'),  'foo valid' );
    ok( !$form->valid('bar'), 'bar not valid' );
    ok( $form->valid('baz'),  'baz valid' );
}

# Invalid
{
    $form->process( {
            foo => 'yada',
            bar => 'x',
            baz => 'yada',
        } );

    ok( $form->valid('foo'),  'foo valid' );
    ok( $form->valid('bar'),  'bar valid' );
    ok( !$form->valid('baz'), 'baz not valid' );
}

# Invalid
{
    $form->process( {
            foo => 'yada',
            bar => 'yada',
            baz => 'yada',
        } );

    ok( $form->valid('foo'),  'foo valid' );
    ok( !$form->valid('bar'), 'bar not valid' );
    ok( !$form->valid('baz'), 'baz not valid' );
}
