use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->params_ignore_underscore(1);

$form->element('Text')->name('foo');
$form->element('Text')->name('bar');
$form->element('Text')->name('_baz');

$form->process( {
        foo  => 'a',
        bar  => 'b',
        _baz => 'c',
    } );

is_deeply(
    $form->params,
    {
        foo => 'a',
        bar => 'b',
    }
);

ok( !grep { $_ eq '_baz' } $form->valid );

is( $form->param('_baz'), undef );
