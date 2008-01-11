use strict;
use warnings;

use Test::More tests => 10 + 1;
use Test::NoWarnings;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->auto_fieldset( { nested_name => 'radio' } );

$form->element('Radio')->name('foo')->value('a')->retain_default(1);
$form->element('Radio')->name('fox')->value('b')->retain_default(1);
$form->element('Radio')->name('bar')->value('c');

$form->process( {
        "radio.foo" => '',
        "radio.bar" => '',
    } );

ok( $form->valid('radio.foo') );
ok( !$form->valid('radio.fox') );
ok( $form->valid('radio.bar') );

is( $form->param('radio.foo'), '' );
is( $form->param('radio.fox'), undef );
is( $form->param('radio.bar'), '' );

like( $form->get_field('foo'), qr/value="a" [^>] checked="checked"/x );
like( $form->get_field('fox'), qr/value="b" [^>] checked="checked"/x );
like( $form->get_field('bar'), qr/value="c"/ );
unlike( $form->get_field('bar'), qr/checked/ );
