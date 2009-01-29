use strict;
use warnings;

use Test::More tests => 9;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo')->constraint('Equal')
    ->others( 'bar', 'baz' )->not(1);

$form->element('Text')->name('bar');
$form->element('Text')->name('baz');

# Valid
{
    $form->process( {
            foo => 'yada',
            bar => 'boba',
            baz => 'sith',
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
    ok( $form->valid('bar'), 'baz valid' );
}
#local $ENV{HTML_FORMFU_DEBUG} = 1;
# Valid
{
    $form->process( {
            foo => '',
            bar => '',
            baz => '',
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
    ok( $form->valid('baz'), 'baz valid' );
}
#local $ENV{HTML_FORMFU_DEBUG} = 0;
# Invalid
{
    $form->process( {
            foo => 'yada',
            bar => 'yada',
            baz => 'x',
        } );

    ok( $form->valid('foo'),  'foo valid' );
    ok( !$form->valid('bar'), 'bar not valid' );
    ok( $form->valid('baz'),  'baz valid' );
}
