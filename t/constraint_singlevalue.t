use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo');
$form->element('text')->name('bar');
$form->element('text')->name('baz');
$form->element('text')->name('bif');
$form->element('text')->name('bom');

$form->constraint('SingleValue');

$form->process( {
        foo => 1,
        bar => '',
        baz => [2],
        bif => [ 3, 4 ],
    } );

is_deeply( [ $form->has_errors ], ['bif'] );

