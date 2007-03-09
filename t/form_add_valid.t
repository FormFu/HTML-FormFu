use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo');
$form->element('text')->name('bar');

$form->process( { foo => 1, } );

is_deeply( $form->params, { foo => 1, } );

$form->add_valid( bar => 'b' );

is_deeply(
    $form->params,
    {   foo => 1,
        bar => 'b',
    } );

my $bar_xhtml = qq{<span class="text">
<input name="bar" type="text" value="b" />
</span>};

is( $form->get_field('bar'), $bar_xhtml );

