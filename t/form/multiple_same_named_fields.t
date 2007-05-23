use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $foo1 = $form->element('text')->name('foo');
my $foo2 = $form->element('text')->name('foo');


$form->process( {
    foo => [qw/ a b /],
} );

is( $foo1->render->{value}, 'a' );
is( $foo2->render->{value}, 'b' );
