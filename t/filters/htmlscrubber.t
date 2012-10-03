use strict;
use warnings;

use Test::More tests => 6;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo')->filter('HTMLScrubber');
$form->element('Text')->name('bar')->filter('HTMLScrubber')->allow( ['b'] );
$form->element('Text')->name('fum')->filter('HTMLScrubber')
    ->rules( [ '*' => 0, p => { '*' => 0 }, a => { href => 1, '*' => 0 } ] );

my $original_foo = "<p>message</p>";
my $filtered_foo = "message";

my $original_bar = "<p><b>message</b></p>";
my $filtered_bar = "<b>message</b>";

my $original_fum
    = "<p class=\"y\"><b>message</b><a href=\"#somewhere\" class=\"x\">text</a></p>";
my $filtered_fum = "<p>message<a href=\"#somewhere\">text</a></p>";

$form->process( {
        foo => $original_foo,
        bar => $original_bar,
        fum => $original_fum,
    } );

# foo is quoted
is( $form->param('foo'),  $filtered_foo, 'foo filtered' );
is( $form->params->{foo}, $filtered_foo, 'foo filtered' );

# bar is filtered
is( $form->param('bar'),  $filtered_bar, 'bar filtered' );
is( $form->params->{bar}, $filtered_bar, 'bar filtered' );

# fum is filtered
is( $form->param('fum'),  $filtered_fum, 'fum filtered' );
is( $form->params->{fum}, $filtered_fum, 'fum filtered' );

