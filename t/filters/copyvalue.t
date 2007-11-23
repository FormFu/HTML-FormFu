use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo');
$form->element('Text')->name('bar')->filter('CopyValue')->field('foo');

my $original_foo = "ab123456";
my $filtered_foo = "ab123456";

my $filtered_bar = $filtered_foo;

$form->process( {
        foo => $original_foo,
        bar => undef,
    } );

# foo is quoted
is( $form->param('foo'), $filtered_foo, 'foo filtered' );
is( $form->params->{foo}, $filtered_foo, 'foo filtered' );

# bar is filtered
is( $form->param('bar'), $filtered_bar, 'bar filtered' );
is( $form->params->{bar}, $filtered_bar, 'bar filtered' );

