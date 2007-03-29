use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo')
    ->constraint('CallbackOnce')->callback(
    sub {
        is_deeply( \@_, [ 1, { foo => 1, bar => [ 0, 'a' ] } ] );
        return 1;
    } );

$form->element('text')->name('bar')
    ->constraint('CallbackOnce')->callback(
    sub {
        is_deeply( \@_, [ [ 0, 'a' ], { foo => 1, bar => [ 0, 'a' ] } ] );
        return 1;
    } );

# Valid
{
    $form->process( {
            foo => 1,
            bar => [ 0, 'a' ],
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
}
