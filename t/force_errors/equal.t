use strict;
use warnings;

use Test::More tests => 31;

use HTML::FormFu;

my $form = HTML::FormFu->new->force_errors(1);

$form->element('Text')->name('foo')->constraint('Equal')
    ->others( 'bar', 'baz' );
$form->element('Text')->name('bar');
$form->element('Text')->name('baz');

# valid
{
    $form->process( {
            foo => 'yada',
            bar => 'yada',
            baz => 'yada',
        } );

    ok( $form->submitted_and_valid );

    ok( !$form->has_errors('foo') );
    ok( !$form->has_errors('bar') );
    ok( !$form->has_errors('baz') );

    ok( @{ $form->get_errors( { name => 'foo', forced => 1 } ) } );
    ok( @{ $form->get_errors( { name => 'bar', forced => 1 } ) } );
    ok( @{ $form->get_errors( { name => 'baz', forced => 1 } ) } );
}

# valid
{
    $form->process( {
            foo => '',
            bar => '',
            baz => '',
        } );

    ok( $form->submitted_and_valid );

    ok( !$form->has_errors('foo') );
    ok( !$form->has_errors('bar') );
    ok( !$form->has_errors('baz') );

    ok( @{ $form->get_errors( { name => 'foo', forced => 1 } ) } );
    ok( @{ $form->get_errors( { name => 'bar', forced => 1 } ) } );
    ok( @{ $form->get_errors( { name => 'baz', forced => 1 } ) } );
}

# valid
{
    $form->process( {
            foo => [ 'a', 'b' ],
            bar => [ 'a', 'b' ],
            baz => [ 'b', 'a' ],
        } );

    ok( $form->submitted_and_valid );

    ok( !$form->has_errors('foo') );
    ok( !$form->has_errors('bar') );
    ok( !$form->has_errors('baz') );

    ok( @{ $form->get_errors( { name => 'foo', forced => 1 } ) } );
    ok( @{ $form->get_errors( { name => 'bar', forced => 1 } ) } );
    ok( @{ $form->get_errors( { name => 'baz', forced => 1 } ) } );
}

# invalid
{
    $form->process( {
            foo => 'yada',
            bar => 'yada',
            baz => 'x',
        } );

    ok( !$form->submitted_and_valid );

    ok( !$form->has_errors('foo') );
    ok( !$form->has_errors('bar') );
    ok( $form->has_errors('baz') );

    ok( @{ $form->get_errors( { name => 'baz', forced => 1 } ) } );
}

# invalid
{
    $form->process( {
            foo => [ 'a', 'b' ],
            bar => [ 'a', 'b' ],
            baz => ['a'],
        } );

    ok( !$form->submitted_and_valid );

    ok( !$form->has_errors('foo') );
    ok( !$form->has_errors('bar') );
    ok( $form->has_errors('baz') );

    ok( @{ $form->get_errors( { name => 'baz', forced => 1 } ) } );
}
