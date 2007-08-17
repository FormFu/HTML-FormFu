use strict;
use warnings;

use Test::More tests => 8;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo');
$form->element('Text')->name('bar');

$form->constraint('Integer');

# Valid
# linebreak not valid
{
    $form->process( {
            foo => '12',
            bar => "12\n",
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( !$form->valid('bar'), 'bar valid' );

    ok( grep  { $_ eq 'foo' } $form->valid );
    ok( !grep { $_ eq 'bar' } $form->valid );
}

# "0" is valid
# linebreak not valid
{
    $form->process( {
            foo => 0,
            bar => "0\n",
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( !$form->valid('bar'), 'foo valid' );

    ok( grep  { $_ eq 'foo' } $form->valid );
    ok( !grep { $_ eq 'bar' } $form->valid );
}
