use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->plugins({
    type  => 'StashValid',
    names => ['foo'],
});

$form->element('Text')->name('foo');
$form->element('Text')->name('bar');

$form->process( {
        foo => 'a',
        bar => 'b',
    } );

is( $form->stash->{foo}, 'a' );
is( $form->stash->{bar}, undef );
