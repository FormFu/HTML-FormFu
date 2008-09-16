use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo');
$form->element('Text')->name('bar');
$form->element('Text')->name('baz');

$form->process( {
        foo => 'a',
        bar => [ 'b', 'c' ],
    } );

is_deeply( [ $form->param_list('foo') ], ['a'] );

is_deeply( [ $form->param_list('bar') ], [ 'b', 'c' ] );

is_deeply( [ $form->param_list('baz') ], [] );
