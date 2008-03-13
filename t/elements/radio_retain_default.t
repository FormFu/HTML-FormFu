use strict;
use warnings;

use Test::More tests => 10 + 1;
use Test::NoWarnings;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Radio')->name('foo')->value('a')->retain_default(1);
$form->element('Radio')->name('fox')->value('b')->retain_default(1);
$form->element('Radio')->name('bar')->value('c');

$form->process( {
        foo => '',
        bar => '',
    } );

ok( $form->valid('foo') );
ok( !$form->valid('fox') );
ok( $form->valid('bar') );

is( $form->param('foo'), '' );
is( $form->param('fox'), undef );
is( $form->param('bar'), '' );

like( $form->get_field('foo'), qr/value="a" [^>] checked="checked"/x );
like( $form->get_field('fox'), qr/value="b" [^>] checked="checked"/x );
like( $form->get_field('bar'), qr/value="c"/ );
unlike( $form->get_field('bar'), qr/checked/ );
