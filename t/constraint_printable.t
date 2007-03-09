use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo');
$form->element('text')->name('bar');

$form->constraint('Printable');

# Valid
{
    $form->process( {
            foo => 'aaa',
            bar => 'bbbbbbb',
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
}

# Invalid
{
    $form->process( {
            foo => 'aaa',
            bar => '日本語',
        } );

    ok( $form->valid('foo'),      'foo valid' );
    ok( $form->has_errors('bar'), 'bar has errors' );
}

