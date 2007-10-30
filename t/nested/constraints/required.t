use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->auto_fieldset( { nested_name => 'foo' } );

$form->element('Text')->name('bar')->constraint('Required');
$form->element('Text')->name('baz')->constraint('Required');


$form->process({
    'foo.bar' => 'x',
});

ok( !$form->has_errors('foo.bar') );

ok( $form->has_errors('foo.baz') );
