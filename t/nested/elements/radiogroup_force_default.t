use strict;
use warnings;

use Test::More tests => 9 + 1;
use Test::NoWarnings;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->auto_fieldset( { nested_name => 'rg' } );

$form->element('Radiogroup')->name('foo')->values( [qw/ one two three /] )
    ->default('two')->force_default(1);
$form->element('Radiogroup')->name('bar')->values( [qw/ one two three /] )
    ->default('one')->force_default(1);
$form->element('Radiogroup')->name('baz')->values( [qw/ one two three /] )
    ->default('three')->force_default(1);

$form->process( {
        "rg.foo" => '',
        "rg.bar" => 'three',
    } );

ok( $form->valid('rg.foo') );
ok( $form->valid('rg.bar') );
ok( $form->valid('rg.baz') );

is( $form->param('rg.foo'), 'two' );
is( $form->param('rg.bar'), 'one' );
is( $form->param('rg.baz'), 'three' );

like( $form->get_field('foo'), qr/value="two" [^>]* checked="checked"/x );
like( $form->get_field('bar'), qr/value="one" [^>]* checked="checked"/x );
like( $form->get_field('baz'), qr/value="three" [^>]* checked="checked"/x );
