use strict;
use warnings;

use Test::More tests => 5;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo')->constraint('MaxLength')->max(5);
$form->element('Text')->name('bar')->constraint('MaxLength')->max(5);

# Valid
{
    $form->process( {
            foo => 'abc',
            bar => 'abcde',
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

    ok( $form->valid('foo'), 'foo valid' );
    ok( !$form->valid('bar'), 'bar not valid' );

    is( $form->get_error('bar')->message,
        'Must not be longer than 5 characters long' );
}

