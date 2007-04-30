use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo')
    ->constraint('CallbackOnce')->force_errors(1)->callback(
    sub {
        return $_[0] eq 'a';
    } );

$form->element('text')->name('bar')
    ->constraint('CallbackOnce')->force_errors(1)->callback(
    sub {
        return $_[0] eq 'b';
    } );

{
    $form->process( {
            foo => 'a',
            bar => 'c',
        } );

    ok( $form->has_errors('foo'), 'foo valid' );
    ok( $form->has_errors('bar'), 'bar valid' );
    
    ok( !$form->get_errors('foo')->[0]{forced} );
    ok( $form->get_errors('bar')->[0]{forced} );
}
