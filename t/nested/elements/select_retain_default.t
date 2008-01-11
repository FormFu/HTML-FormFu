use strict;
use warnings;

use Test::More tests => 9 + 1;
use Test::NoWarnings;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->auto_fieldset( { nested_name => 'select' } );

$form->element('Select')->name('foo')->values( [qw/ one two three /] )
    ->default('two')->retain_default(1);
$form->element('Select')->name('bar')->values( [qw/ one two three /] )
    ->default('one');
$form->element('Select')->name('baz')->values( [qw/ one two three /] )
    ->default('three')->retain_default(1);

$form->process( {
        "select.foo" => '',
        "select.bar" => '',
    } );

ok( $form->valid('select.foo') );
ok( $form->valid('select.bar') );
ok( !$form->valid('select.baz') );

is( $form->param('select.foo'), '' );
is( $form->param('select.bar'), '' );
is( $form->param('select.baz'), undef );

like( $form->get_field('foo'), qr/value="two" [^>]* selected="selected"/x );
unlike( $form->get_field('bar'), qr/selected/ );
like( $form->get_field('baz'), qr/value="three" [^>]* selected="selected"/x );
