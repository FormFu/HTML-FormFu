use strict;
use warnings;

use Test::More tests => 5;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo');
$form->element('Text')->name('bar');

$form->process( { foo => 1, } );

is_deeply( $form->params, { foo => 1, } );

$form->add_valid( bar => 'b' );

is_deeply(
    $form->params,
    {   foo => 1,
        bar => 'b',
    } );

like( $form->get_field('bar'), qr/value="b"/ );

# nested names

$form->add_valid( 'block.foo', 'abc' );

is_deeply(
    $form->params,
    {   foo   => 1,
        bar   => 'b',
        block => { foo => 'abc', } } );

$form->add_valid( 'block.bar', 'def' );

is_deeply(
    $form->params,
    {   foo   => 1,
        bar   => 'b',
        block => {
            foo => 'abc',
            bar => 'def',
        } } );
