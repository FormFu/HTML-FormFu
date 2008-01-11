use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new;

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

