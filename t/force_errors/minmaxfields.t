use strict;
use warnings;

use Test::More tests => 18;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo')
    ->constraint('MinMaxFields')
    ->others(qw/ bar baz boz/)
    ->min(1)
    ->max(2)
    ->force_errors(1);
$form->element('text')->name('bar');
$form->element('text')->name('baz');
$form->element('text')->name('boz');

{
    $form->process( {
            foo => 1,
            bar => '',
            baz => [2],
            boz => '',
        } );

    ok( $form->has_errors );
    
    ok( $form->has_errors('foo') );
    ok( !$form->has_errors('bar') );
    ok( !$form->has_errors('baz') );
    ok( !$form->has_errors('boz') );
    
    ok( $form->get_errors('foo')->[0]{forced} );
}

{
    $form->process( {
            foo => 1,
            bar => '',
            baz => '',
            boz => '',
        } );

    ok( $form->has_errors );
    
    ok( $form->has_errors('foo') );
    ok( !$form->has_errors('bar') );
    ok( !$form->has_errors('baz') );
    ok( !$form->has_errors('boz') );
    
    ok( $form->get_errors('foo')->[0]{forced} );
}

{
    $form->process( {
            foo => 1,
            bar => '',
            baz => 2,
            boz => '22',
        } );

    ok( $form->has_errors );
    
    ok( $form->has_errors('foo') );
    ok( !$form->has_errors('bar') );
    ok( !$form->has_errors('baz') );
    ok( !$form->has_errors('boz') );
    
    ok( !$form->get_errors('foo')->[0]{forced} );
}
