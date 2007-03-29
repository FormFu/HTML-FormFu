use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo')->filter('LowerCase');

my $original_foo = "Foo Bar";
my $filtered_foo = "foo bar";

$form->process( { foo => $original_foo, } );

# foo is filtered
is( $form->param('foo'), $filtered_foo, 'foo filtered' );
is( $form->params->{foo}, $filtered_foo, 'foo filtered' );

