use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo')->constraint('Not_Equal')->others('bar');
$form->element('Text')->name('bar');

# Valid
{
    $form->process( {
            foo => 'yada',
            bar => 'xxxx',
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
}

# Invalid
{
    $form->process( {
            foo => 'yada',
            bar => 'yada',
        } );

    ok( $form->valid('foo'),      'foo valid' );
    ok( $form->has_errors('bar'), 'bar valid' );
}
