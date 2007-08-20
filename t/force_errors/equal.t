use strict;
use warnings;

use Test::More tests => 23;

use HTML::FormFu;

my $form = HTML::FormFu->new->force_errors(1);

$form->element('Text')->name('foo')->constraint('Equal')
    ->others( 'bar', 'baz' );
$form->element('Text')->name('bar');
$form->element('Text')->name('baz');

{
    $form->process( {
            foo => 'yada',
            bar => 'yada',
            baz => 'yada',
        } );

    ok( !$form->has_errors('foo') );
    ok( !$form->has_errors('bar') );
    ok( !$form->has_errors('baz') );

    ok( $form->get_errors( { name => 'bar', forced => 1 } ) );
    ok( $form->get_errors( { name => 'baz', forced => 1 } ) );
}

{
    $form->process( {
            foo => '',
            bar => '',
            baz => '',
        } );

    ok( !$form->has_errors('foo') );
    ok( !$form->has_errors('bar') );
    ok( !$form->has_errors('baz') );

    ok( $form->get_errors( { name => 'bar', forced => 1 } ) );
    ok( $form->get_errors( { name => 'baz', forced => 1 } ) );
}

{
    $form->process( {
            foo => [ 'a', 'b' ],
            bar => [ 'a', 'b' ],
            baz => [ 'b', 'a' ],
        } );

    ok( !$form->has_errors('foo') );
    ok( !$form->has_errors('bar') );
    ok( !$form->has_errors('baz') );

    ok( $form->get_errors( { name => 'bar', forced => 1 } ) );
    ok( $form->get_errors( { name => 'baz', forced => 1 } ) );
}

{
    $form->process( {
            foo => 'yada',
            bar => 'yada',
            baz => 'x',
        } );

    ok( !$form->has_errors('foo') );
    ok( !$form->has_errors('bar') );
    ok( $form->has_errors('baz') );

    ok( $form->get_errors( { name => 'baz', forced => 1 } ) );
}

{
    $form->process( {
            foo => [ 'a', 'b' ],
            bar => [ 'a', 'b' ],
            baz => ['a'],
        } );

    ok( !$form->has_errors('foo') );
    ok( !$form->has_errors('bar') );
    ok( $form->has_errors('baz') );

    ok( $form->get_errors( { name => 'baz', forced => 1 } ) );
}
