use strict;
use warnings;

use Test::More tests => 5;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo')->constraint('MinLength')->min(3);
$form->element('Text')->name('bar')->constraint('MinLength')->min(3);

# Valid
{
    $form->process( {
            foo => 'abc',
            bar => 'abcd',
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
}

# Invalid
{
    $form->process( {
            foo => 'ab',
            bar => 'abcdef',
        } );

    ok( !$form->valid('foo'), 'foo not valid' );
    ok( $form->valid('bar'), 'bar valid' );

    is( $form->get_error('foo')->message,
        'Must be at least 3 characters long' );
}

