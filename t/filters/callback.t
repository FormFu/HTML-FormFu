use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo')->filter('Callback')
    ->callback( sub { $_[0] =~ s/(\d)(\d)/$2$1/g; shift; } );
$form->element('Text')->name('bar')->filter('Callback');

my $original_foo = "ab123456";
my $filtered_foo = "ab214365";

my $original_bar = "ab123456";
my $filtered_bar = "ab123456";

$form->process( {
        foo => $original_foo,
        bar => $original_bar,
    } );

# foo is quoted
is( $form->param('foo'), $filtered_foo, 'foo filtered' );
is( $form->params->{foo}, $filtered_foo, 'foo filtered' );

# bar is filtered
is( $form->param('bar'), $filtered_bar, 'bar filtered' );
is( $form->params->{bar}, $filtered_bar, 'bar filtered' );

