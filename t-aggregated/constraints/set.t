use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo')->constraint('Set')->set( [qw/ yes no /] );
$form->element('Text')->name('bar')->constraint('Set')->set( [qw/ yes no /] );

# Valid
{
    $form->process( {
            foo => 'yes',
            bar => 'no',
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
}

# Invalid
{
    $form->process( {
            foo => 'yes',
            bar => 'x',
        } );

    ok( $form->valid('foo'),      'foo valid' );
    ok( $form->has_errors('bar'), 'bar has_errors' );
}
