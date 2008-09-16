use strict;
use warnings;

use Test::More tests => 9 + 1;
use Test::NoWarnings;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Radiogroup')->name('foo')->values( [qw/ one two three /] )
    ->default('two')->force_default(1);
$form->element('Radiogroup')->name('bar')->values( [qw/ one two three /] )
    ->default('one')->force_default(1);
$form->element('Radiogroup')->name('baz')->values( [qw/ one two three /] )
    ->default('three')->force_default(1);

$form->process( {
        foo => '',
        bar => 'three',
    } );

ok( $form->valid('foo') );
ok( $form->valid('bar') );
ok( $form->valid('baz') );

is( $form->param('foo'), 'two' );
is( $form->param('bar'), 'one' );
is( $form->param('baz'), 'three' );

like( $form->get_field('foo'), qr/value="two" [^>]* checked="checked"/x );
like( $form->get_field('bar'), qr/value="one" [^>]* checked="checked"/x );
like( $form->get_field('baz'), qr/value="three" [^>]* checked="checked"/x );
