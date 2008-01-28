use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo')->filter('HTMLScrubber');
$form->element('Text')->name('bar')->filter('HTMLScrubber')->allow( ['b'] );

my $original_foo = "<p>message</p>";
my $filtered_foo = "message";

my $original_bar = "<p><b>message</b></p>";
my $filtered_bar = "<b>message</b>";

$form->process( {
        foo => $original_foo,
        bar => $original_bar,
    } );

# foo is quoted
is( $form->param('foo'),  $filtered_foo, 'foo filtered' );
is( $form->params->{foo}, $filtered_foo, 'foo filtered' );

# bar is filtered
is( $form->param('bar'),  $filtered_bar, 'bar filtered' );
is( $form->params->{bar}, $filtered_bar, 'bar filtered' );

