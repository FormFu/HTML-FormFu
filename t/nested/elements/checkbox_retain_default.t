use strict;
use warnings;

use Test::More tests => 10 + 1;
use Test::NoWarnings;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->auto_fieldset( { nested_name => 'cb' } );

$form->element('Checkbox')->name('foo')->value('a')->retain_default(1);
$form->element('Checkbox')->name('fox')->value('b')->retain_default(1);
$form->element('Checkbox')->name('bar')->value('c');

$form->process( {
        "cb.foo" => '',
        "cb.bar" => '',
    } );

ok( $form->valid('cb.foo') );
ok( !$form->valid('cb.fox') );
ok( $form->valid('cb.bar') );

is( $form->param('cb.foo'), '' );
is( $form->param('cb.fox'), undef );
is( $form->param('cb.bar'), '' );

like( $form->get_field('foo'), qr/value="a" [^>] checked="checked"/x );
like( $form->get_field('fox'), qr/value="b" [^>] checked="checked"/x );
like( $form->get_field('bar'), qr/value="c"/ );
unlike( $form->get_field('bar'), qr/checked/ );
