use strict;
use warnings;

use Test::More tests => 15 + 1;
use Test::NoWarnings;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Password')->name('foo')->value('a');
$form->element('Password')->name('bar')->value('b')->render_value(1);
$form->element('Password')->name('baz')->value('c')->retain_default(1);
$form->element('Password')->name('doo')->value('d')->retain_default(1)
    ->render_value(1);
$form->element('Password')->name('doc')->value('e')->retain_default(1)
    ->render_value(1);

$form->process( {
        foo => '',
        bar => '',
        baz => '',
        doo => '',
    } );

ok( $form->valid('foo') );
ok( $form->valid('bar') );
ok( $form->valid('baz') );
ok( $form->valid('doo') );
ok( !$form->valid('doc') );

is( $form->param('foo'), '' );
is( $form->param('bar'), '' );
is( $form->param('baz'), '' );
is( $form->param('doo'), '' );
is( $form->param('doc'), undef );

like( $form->get_field('foo'), qr/value=""/ );
like( $form->get_field('bar'), qr/value=""/ );
like( $form->get_field('baz'), qr/value=""/ );
like( $form->get_field('doo'), qr/value="d"/ );
like( $form->get_field('doc'), qr/value="e"/ );
