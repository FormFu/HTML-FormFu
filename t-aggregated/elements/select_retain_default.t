use strict;
use warnings;

use Test::More tests => 9 + 1;
use Test::NoWarnings;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Select')->name('foo')->values( [qw/ one two three /] )
    ->default('two')->retain_default(1);
$form->element('Select')->name('bar')->values( [qw/ one two three /] )
    ->default('one');
$form->element('Select')->name('baz')->values( [qw/ one two three /] )
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

like( $form->get_field('foo'), qr/value="two" [^>]* selected="selected"/x );
unlike( $form->get_field('bar'), qr/selected/ );
like( $form->get_field('baz'), qr/value="three" [^>]* selected="selected"/x );
