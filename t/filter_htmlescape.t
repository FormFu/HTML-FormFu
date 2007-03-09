use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo')->filter('HTMLEscape');

my $original_foo = qq{&escape "this"};
my $filtered_foo = "&amp;escape &quot;this&quot;";

$form->process( { foo => $original_foo, } );

# foo is filtered
is( $form->param('foo'), $filtered_foo, 'foo filtered' );
is( $form->params->{foo}, $filtered_foo, 'foo filtered' );

