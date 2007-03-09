use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo');
$form->element('text')->name('bar');

$form->constraint('Bool');

# Valid
{
    $form->process( {
            foo => 1,
            bar => 0,
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
}

# Invalid
{
    $form->process( {
            foo => '1',
            bar => 'a',
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( !$form->valid('bar'), 'bar not valid' );
}

