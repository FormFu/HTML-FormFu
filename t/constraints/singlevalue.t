use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo');
$form->element('Text')->name('bar');
$form->element('Text')->name('baz');
$form->element('Text')->name('bif');
$form->element('Text')->name('bom');

$form->constraint('SingleValue');

$form->process( {
        foo => 1,
        bar => '',
        baz => [2],
        bif => [ 3, 4 ],
    } );

is_deeply( [ $form->has_errors ], ['bif'] );

