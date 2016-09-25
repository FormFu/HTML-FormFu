use strict;
use warnings;

use Test::More tests => 9;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->auto_fieldset( { nested_name => 'rg' } );

$form->element('Radiogroup')->name('foo')->values( [qw/ one two three /] )
    ->default('two')->retain_default(1);
$form->element('Radiogroup')->name('bar')->values( [qw/ one two three /] )
    ->default('one');
$form->element('Radiogroup')->name('baz')->values( [qw/ one two three /] )
    ->default('three')->retain_default(1);

$form->process( {
        "rg.foo" => '',
        "rg.bar" => '',
    } );

ok( $form->valid('rg.foo') );
ok( $form->valid('rg.bar') );
ok( !$form->valid('rg.baz') );

is( $form->param('rg.foo'), '' );
is( $form->param('rg.bar'), '' );
is( $form->param('rg.baz'), undef );

like( $form->get_field('foo'), qr/value="two" [^>]* checked="checked"/x );
unlike( $form->get_field('bar'), qr/checked/ );
like( $form->get_field('baz'), qr/value="three" [^>]* checked="checked"/x );
