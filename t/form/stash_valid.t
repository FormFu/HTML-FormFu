use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->stash_valid( ['foo'] );

$form->element('Text')->name('foo');
$form->element('Text')->name('bar');

$form->process( {
        foo => 'a',
        bar => 'b',
    } );

is( $form->stash->{foo}, 'a' );
is( $form->stash->{bar}, undef );
