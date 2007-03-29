use strict;
use warnings;

use Test::More tests => 9 + 1;
use Test::NoWarnings;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('radiogroup')->name('foo')->values( [qw/ one two three /] )
    ->default('two')->retain_default(1);
$form->element('radiogroup')->name('bar')->values( [qw/ one two three /] )
    ->default('one');
$form->element('radiogroup')->name('baz')->values( [qw/ one two three /] )
    ->default('three')->retain_default(1);

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

like( $form->get_field('foo'), qr/value="two" [^>]* checked="checked"/x );
unlike( $form->get_field('bar'), qr/checked/ );
like( $form->get_field('baz'), qr/value="three" [^>]* checked="checked"/x );
