use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo');
$form->element('Text')->name('bar');
$form->element('Text')->name('baz');

$form->process( {
        foo => 'a',
        bar => [ 'b', 'c' ],
    } );

is( $form->param_value('foo'), 'a' );

is( $form->param_value('bar'), 'b' );

my @baz = $form->param_value('baz');

# we got 1 value

ok( @baz == 1 );

# it was undef

is( $baz[0], undef );
