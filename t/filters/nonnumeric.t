use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo')->filter('NonNumeric');

my $original_foo = " 0123-4567 (8a9)";
my $filtered_foo = "0123456789";

$form->process( { foo => $original_foo, } );

# foo is filtered
is( $form->param('foo'), $filtered_foo, 'foo filtered' );
is( $form->params->{foo}, $filtered_foo, 'foo filtered' );

