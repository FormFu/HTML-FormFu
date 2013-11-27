use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $foo = $form->element('Text')->name('foo');
my $bar = $form->element('Text')->name('bar');

$foo->constraint({
    type     => 'Regex',
    regex    => 'xxx',
});

$bar->constraint({
    type     => 'Regex',
    regex    => 'xxx',
    anchored => 1,
});

# Valid
{
    $form->process( {
            foo => ' xxx ',
            bar => 'xxx',
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
}

# Invalid
{
    $form->process( {
            foo => ' xxx ',
            bar => ' xxx ',
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( ! $form->valid('bar'), 'foo invalid' );
}
