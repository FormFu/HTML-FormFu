use strict;
use warnings;

use Test::More tests => 16;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo');
$form->element('Text')->name('bar');

$form->constraint('Word');

# Valid
{
    $form->process( {
            foo => 'aaa',
            bar => 'bbbbbbb',
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );

    ok( grep { $_ eq 'foo' } $form->valid );
    ok( grep { $_ eq 'bar' } $form->valid );
}

# [space] - Invalid
{
    $form->process( {
            foo => 'a',
            bar => 'b c',
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( !$form->valid('bar'), 'foo valid' );

    ok( grep  { $_ eq 'foo' } $form->valid );
    ok( !grep { $_ eq 'bar' } $form->valid );
}

# [newline] - Invalid
{
    $form->process( {
            foo => 'a',
            bar => "b\nc",
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( !$form->valid('bar'), 'foo valid' );

    ok( grep  { $_ eq 'foo' } $form->valid );
    ok( !grep { $_ eq 'bar' } $form->valid );
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
