use strict;
use warnings;

use Test::More tests => 6;

use HTML::FormFu;
use lib 'lib';

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo')->filter('Callback')
    ->callback( sub { $_[0] =~ s/(\d)(\d)/$2$1/g; shift; } );

$form->element('Text')->name('bar')->filter('Callback');

$form->element('Text')->name('baz')->filter('Callback')
    ->callback('FilterCallback::my_filter');

my $original_foo = "ab123456";
my $filtered_foo = "ab214365";

my $original_bar = "ab123456";
my $filtered_bar = "ab123456";

my $original_baz = "abcdef";
my $filtered_baz = "ABCdef";

$form->process( {
        foo => $original_foo,
        bar => $original_bar,
        baz => $original_baz,
    } );

# foo is quoted
is( $form->param('foo'),  $filtered_foo, 'foo filtered' );
is( $form->params->{foo}, $filtered_foo, 'foo filtered' );

# bar is filtered
is( $form->param('bar'),  $filtered_bar, 'bar filtered' );
is( $form->params->{bar}, $filtered_bar, 'bar filtered' );

# baz is filtered
is( $form->param('baz'),  $filtered_baz, 'baz filtered' );
is( $form->params->{baz}, $filtered_baz, 'baz filtered' );

{

    package FilterCallback;
    use strict;
    use warnings;

    sub my_filter {
        my ($value) = @_;

        $value =~ tr/abc/ABC/;

        return $value;
    }
}
