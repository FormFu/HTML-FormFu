use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo');
$form->element('Text')->name('bar');

$form->constraint('Not_Word');

# Valid
{
    $form->process( {
            foo => ' ',
            bar => "\t",
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
}

# Invalid
{
    $form->process( {
            foo => 'a',
            bar => "\n",
        } );

    ok( $form->has_errors('foo'), 'foo has_errors' );
    ok( $form->valid('bar'),      'bar valid' );
}
