use strict;
use warnings;

use Test::More tests => 20 + 1;
use Test::NoWarnings;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->auto_fieldset( { nested_name => 'radio' } );

$form->element('Radio')->name('foo')->value('a')->force_default(1);
$form->element('Radio')->name('fox')->value('b')->force_default(1);
$form->element('Radio')->name('bar')->value('c')->checked('checked')
    ->force_default(1);
$form->element('Radio')->name('bax')->value('d')->checked('checked')
    ->force_default(1);
$form->element('Radio')->name('moo')->value('e')->default('e')
    ->force_default(1);
$form->element('Radio')->name('mox')->value('f')->default('f')
    ->force_default(1);

$form->process( {
        "radio.foo" => '',
        "radio.bar" => 'z',
        "radio.moo" => 'y',
    } );

ok( $form->valid('radio.foo') );
ok( $form->valid('radio.fox') );
ok( $form->valid('radio.bar') );
ok( $form->valid('radio.bax') );
ok( $form->valid('radio.moo') );
ok( $form->valid('radio.mox') );

is( $form->param('radio.foo'), undef );
is( $form->param('radio.fox'), undef );
is( $form->param('radio.bar'), 'c' );
is( $form->param('radio.bax'), 'd' );
is( $form->param('radio.moo'), 'e' );
is( $form->param('radio.mox'), 'f' );

like( $form->get_field('foo'), qr/value="a"/ );
unlike( $form->get_field('foo'), qr/checked/ );
like( $form->get_field('fox'), qr/value="b"/ );
unlike( $form->get_field('fox'), qr/checked/ );
like( $form->get_field('bar'), qr/value="c" [^>] checked="checked"/x );
like( $form->get_field('bax'), qr/value="d" [^>] checked="checked"/x );
like( $form->get_field('moo'), qr/value="e" [^>] checked="checked"/x );
like( $form->get_field('mox'), qr/value="f" [^>] checked="checked"/x );

