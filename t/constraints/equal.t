use strict;
use warnings;

use Test::More tests => 15;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo')->constraint('Equal')->others( 'bar', 'baz' );
$form->element('text')->name('bar');
$form->element('text')->name('baz');

# Valid
{
    $form->process( {
            foo => 'yada',
            bar => 'yada',
            baz => 'yada',
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
    ok( $form->valid('baz'), 'baz valid' );
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
            foo => [ 'a', 'b' ],
            bar => [ 'a', 'b' ],
            baz => [ 'b', 'a' ],
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
    ok( $form->valid('bar'),  'bar valid' );
    ok( !$form->valid('baz'), 'baz not valid' );
}

# Invalid
{
    $form->process( {
            foo => [ 'a', 'b' ],
            bar => [ 'a', 'b' ],
            baz => ['a'],
        } );

    ok( $form->valid('foo'),  'foo valid' );
    ok( $form->valid('bar'),  'bar valid' );
    ok( !$form->valid('baz'), 'baz not valid' );
}
