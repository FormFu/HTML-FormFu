use strict;
use warnings;

use Test::More tests => 8;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo');
$form->element('Text')->name('bar');

$form->constraint('Regex');

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
