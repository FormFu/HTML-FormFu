use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo')->constraint('Range')->min(3)->max(5);
$form->element('text')->name('bar')->constraint('Range')->min(3)->max(5);

# Valid
{
    $form->process( {
            foo => 3,
            bar => 4,
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
}

# Invalid
{
    $form->process( {
            foo => 1,
            bar => 6,
        } );

    ok( !$form->valid('foo'), 'foo not valid' );
    ok( !$form->valid('bar'), 'bar not valid' );
}
