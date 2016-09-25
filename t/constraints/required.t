use strict;
use warnings;

use Test::More tests => 16;

use HTML::FormFu;
use lib 't/lib';
use HTMLFormFu::TestLib;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo');
$form->element('Text')->name('bar');

$form->constraint('Required');

# Valid
{
    $form->process( {
            foo => 'yada',
            bar => 'nada',
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );

    ok( grep { $_ eq 'foo' } $form->valid );
    ok( grep { $_ eq 'bar' } $form->valid );
}

# Missing - Invalid
{
    $form->process( { foo => 'yada', } );

    ok( $form->valid('foo'),  'foo value' );
    ok( !$form->valid('bar'), 'bar not valid' );

    ok( grep  { $_ eq 'foo' } $form->valid );
    ok( !grep { $_ eq 'bar' } $form->valid );
}

# Empty string - Invalid
{
    $form->process( {
            foo => '',
            bar => 2,
        } );

    ok( !$form->valid('foo'), 'foo not valid' );
    ok( $form->valid('bar'),  'bar valid' );

    ok( !grep { $_ eq 'foo' } $form->valid );
    ok( grep  { $_ eq 'bar' } $form->valid );
}

# "0" is valid
{
    $form->process( {
            foo => 0,
            bar => 2,
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'foo valid' );

    ok( grep { $_ eq 'foo' } $form->valid );
    ok( grep { $_ eq 'bar' } $form->valid );
}
