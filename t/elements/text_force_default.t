use strict;
use warnings;

use Test::More tests => 9 + 1;
use Test::NoWarnings;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo')->default('a')->force_default(1);
$form->element('Text')->name('bar')->default('b')->force_default(1);
$form->element('Text')->name('baz')->default('c')->force_default(1);

$form->process( {
        foo => '',
        bar => 'z',
    } );

ok( $form->valid('foo') );
ok( $form->valid('bar') );
ok( $form->valid('baz') );

is( $form->param('foo'), 'a' );
is( $form->param('bar'), 'b' );
is( $form->param('baz'), 'c' );

like( $form->get_field('foo'), qr/value="a"/ );
like( $form->get_field('bar'), qr/value="b"/ );
like( $form->get_field('baz'), qr/value="c"/ );
