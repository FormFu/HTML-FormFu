use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo')->constraint('Length')->min(3)->max(5);
$form->element('Text')->name('bar')->constraint('Length')->min(3)->max(5);

# Valid
{
    $form->process( {
            foo => 'abc',
            bar => 'abcd',
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
}

# Invalid
{
    $form->process( {
            foo => 'ab',
            bar => 'abcdef',
        } );

    ok( !$form->valid('foo'), 'foo not valid' );
    ok( !$form->valid('bar'), 'bar not valid' );
}
