use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo')->filter('TrimEdges');

my $original_foo = " Foo Bar ";
my $filtered_foo = "Foo Bar";

$form->process({ foo => $original_foo });

# foo is filtered
is( $form->params->{foo}, $filtered_foo );

like( $form->get_field('foo'), qr/$original_foo/ );

