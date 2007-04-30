use strict;
use warnings;

use Test::More tests => 25;

use HTML::FormFu;

my $form = HTML::FormFu->new->force_errors(1);

$form->element('text')->name('foo')->constraint('Equal')->others( 'bar', 'baz' );
$form->element('text')->name('bar');
$form->element('text')->name('baz');

{
    $form->process( {
            foo => 'yada',
            bar => 'yada',
            baz => 'yada',
        } );

    ok( !$form->has_errors('foo') );
    ok( $form->has_errors('bar') );
    ok( $form->has_errors('baz') );
    
    ok( $form->get_errors('bar')->[0]{forced} );
    ok( $form->get_errors('baz')->[0]{forced} );
}

{
    $form->process( {
            foo => '',
            bar => '',
            baz => '',
        } );

    ok( !$form->has_errors('foo') );
    ok( $form->has_errors('bar') );
    ok( $form->has_errors('baz') );
    
    ok( $form->get_errors('bar')->[0]{forced} );
    ok( $form->get_errors('baz')->[0]{forced} );
}

{
    $form->process( {
            foo => [ 'a', 'b' ],
            bar => [ 'a', 'b' ],
            baz => [ 'b', 'a' ],
        } );

    ok( !$form->has_errors('foo') );
    ok( $form->has_errors('bar') );
    ok( $form->has_errors('baz') );
    
    ok( $form->get_errors('bar')->[0]{forced} );
    ok( $form->get_errors('baz')->[0]{forced} );
}

{
    $form->process( {
            foo => 'yada',
            bar => 'yada',
            baz => 'x',
        } );
    
    ok( !$form->has_errors('foo') );
    ok( $form->has_errors('bar') );
    ok( $form->has_errors('baz') );
    
    ok( $form->get_errors('bar')->[0]{forced} );
    ok( ! $form->get_errors('baz')->[0]{forced} );
}

{
    $form->process( {
            foo => [ 'a', 'b' ],
            bar => [ 'a', 'b' ],
            baz => ['a'],
        } );

    ok( !$form->has_errors('foo') );
    ok( $form->has_errors('bar') );
    ok( $form->has_errors('baz') );
    
    ok( $form->get_errors('bar')->[0]{forced} );
    ok( ! $form->get_errors('baz')->[0]{forced} );
}
