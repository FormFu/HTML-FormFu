use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->auto_fieldset( { nested_name => 'foo' } );

$form->element('Text')->name('bar');
$form->element('Text')->name('baz');

$form->filters({
    type    => 'Regex',
    names   => [qw/ foo.bar foo.baz /],
    match   => 'a',
    replace => 'A',
});

$form->process({
    'foo.bar' => 'abc',
    'foo.baz' => 'def',
});

is( $form->param('foo.bar'), 'Abc' );
is( $form->param('foo.baz'), 'def' );

