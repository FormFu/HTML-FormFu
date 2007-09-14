use strict;
use warnings;

use Test::More tests => 20 + 1;
use Test::NoWarnings;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Checkbox')->name('foo')->value('a')->force_default(1);
$form->element('Checkbox')->name('fox')->value('b')->force_default(1);
$form->element('Checkbox')->name('bar')->value('c')->default('c')->force_default(1);
$form->element('Checkbox')->name('bax')->value('d')->default('d')->force_default(1);
$form->element('Checkbox')->name('moo')->value('e')->checked('checked')->force_default(1);
$form->element('Checkbox')->name('mox')->value('f')->checked('checked')->force_default(1);

$form->process( {
        foo => '',
        bar => 'z',
    } );

ok( $form->valid('foo') );
ok( $form->valid('fox') );
ok( $form->valid('bar') );
ok( $form->valid('bax') );
ok( $form->valid('moo') );
ok( $form->valid('mox') );

is( $form->param('foo'), undef );
is( $form->param('fox'), undef );
is( $form->param('bar'), 'c' );
is( $form->param('bax'), 'd' );
is( $form->param('moo'), 'e' );
is( $form->param('mox'), 'f' );

like( $form->get_field('foo'), qr/value="a"/ );
unlike( $form->get_field('foo'), qr/checked/ );
like( $form->get_field('fox'), qr/value="b"/ );
unlike( $form->get_field('fox'), qr/checked/ );
like( $form->get_field('bar'), qr/value="c" [^>] checked="checked"/x );
like( $form->get_field('bax'), qr/value="d" [^>] checked="checked"/x );
like( $form->get_field('moo'), qr/value="e" [^>] checked="checked"/x );
like( $form->get_field('mox'), qr/value="f" [^>] checked="checked"/x );

