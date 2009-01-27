use strict;
use warnings;

use Test::More tests => 9 + 1;
use Test::NoWarnings;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo')->default('a')->retain_default(1);
$form->element('Text')->name('bar')->default('b');
$form->element('Text')->name('baz')->default('c')->retain_default(1);

$form->process( {
        foo => '',
        bar => '',
    } );

ok( $form->valid('foo') );
ok( $form->valid('bar') );
ok( !$form->valid('baz') );

is( $form->param('foo'), '' );
is( $form->param('bar'), '' );
is( $form->param('baz'), undef );

like( $form->get_field('foo'), qr/value="a"/ );
like( $form->get_field('bar'), qr/value=""/ );
like( $form->get_field('baz'), qr/value="c"/ );
