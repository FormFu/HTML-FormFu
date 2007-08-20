use strict;
use warnings;

use Test::More tests => 6;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo');
$form->element('Text')->name('bar');
$form->element('Text')->name('bif')->constraint('Number');

$form->filter( {
        type  => 'HTMLEscape',
        names => [qw/ bar bif /],
    } );

my $original_foo = qq{escape "this"};

my $original_bar = qq{escape "that"};
my $escaped_bar  = qq{escape &quot;that&quot;};

$form->process( {
        foo => $original_foo,
        bar => $original_bar,
        bif => "not a number",
    } );

# foo isn't quoted
is( $form->param('foo'), $original_foo );
is( $form->params->{foo}, $original_foo );

# bar
is( $form->param('bar'), $escaped_bar );
is( $form->params->{bar}, $escaped_bar );

# bif
ok( !defined( $form->param('bif') ) );
ok( !defined( $form->params->{bif} ) );
