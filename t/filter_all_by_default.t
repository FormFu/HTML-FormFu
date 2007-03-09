use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo');
$form->element('text')->name('bar');

# should filter all fields, if no explicit name list
$form->filter('HTMLEscape');

my $original_foo = qq{escape "this"};
my $escaped_foo  = qq{escape &quot;this&quot;};

my $original_bar = qq{escape "that"};
my $escaped_bar  = qq{escape &quot;that&quot;};

$form->process( {
        foo => $original_foo,
        bar => $original_bar,
    } );

# foo
is( $form->param('foo'), $escaped_foo, 'quoted' );
is( $form->params->{foo}, $escaped_foo, 'quoted' );

# bar
is( $form->param('bar'), $escaped_bar, 'quoted' );
is( $form->params->{bar}, $escaped_bar, 'quoted' );
