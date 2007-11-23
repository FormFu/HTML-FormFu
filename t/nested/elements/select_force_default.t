use strict;
use warnings;

use Test::More tests => 9 + 1;
use Test::NoWarnings;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->auto_fieldset( { nested_name => 'select' } );

$form->element('Select')->name('foo')->values( [qw/ one two three /] )
    ->default('two')->force_default(1);
$form->element('Select')->name('bar')->values( [qw/ one two three /] )
    ->default('one')->force_default(1);
$form->element('Select')->name('baz')->values( [qw/ one two three /] )
    ->default('three')->force_default(1);

$form->process( {
        "select.foo" => '',
        "select.bar" => 'three',
    } );

ok( $form->valid('select.foo') );
ok( $form->valid('select.bar') );
ok( $form->valid('select.baz') );

is( $form->param('select.foo'), 'two' );
is( $form->param('select.bar'), 'one' );
is( $form->param('select.baz'), 'three' );

like( $form->get_field('foo'), qr/value="two" [^>]* selected="selected"/x );
like( $form->get_field('bar'), qr/value="one" [^>]* selected="selected"/x );
like( $form->get_field('baz'), qr/value="three" [^>]* selected="selected"/x );
