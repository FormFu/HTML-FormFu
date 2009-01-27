use strict;
use warnings;
use Test::More tests => 4;

use HTML::FormFu;
use lib 'lib';

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo')->inflator('Callback')
    ->callback( sub { return uc($_[0]) } );

$form->element('Text')->name('bar')->inflator('Callback')
    ->callback('InflatorCallback::my_def');

my $original_foo = "abc123";
my $inflated_foo = "ABC123";

my $original_bar = "abcdef";
my $inflated_bar = "ABCdef";

$form->process( {
        foo => $original_foo,
        bar => $original_bar,
    } );

# foo is changed
is( $form->param('foo'),  $inflated_foo, 'foo inflated' );
is( $form->params->{foo}, $inflated_foo, 'foo inflated' );

# bar is changed
is( $form->param('bar'),  $inflated_bar, 'bar inflated' );
is( $form->params->{bar}, $inflated_bar, 'bar inflated' );

{

    package InflatorCallback;
    use strict;
    use warnings;

    sub my_def {
        my ($value) = @_;

        $value =~ tr/abc/ABC/;

        return $value;
    }
}
