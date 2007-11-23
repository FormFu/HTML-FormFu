use strict;
use warnings;

use Test::More tests => 20 + 1;
use Test::NoWarnings;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Radio')->name('foo')->value('a')->force_default(1);
$form->element('Radio')->name('fox')->value('b')->force_default(1);
$form->element('Radio')->name('bar')->value('c')->checked('checked')->force_default(1);
$form->element('Radio')->name('bax')->value('d')->checked('checked')->force_default(1);
$form->element('Radio')->name('moo')->value('e')->default('e')->force_default(1);
$form->element('Radio')->name('mox')->value('f')->default('f')->force_default(1);

$form->process( {
        foo => '',
        bar => 'z',
        moo => 'y',
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

