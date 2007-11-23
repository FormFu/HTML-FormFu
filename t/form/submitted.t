use strict;
use warnings;

use Test::More tests => 6;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo');
$form->element('Text')->name('bar');

# NOT SUBMITTED
{
    ok( !$form->submitted );
}

# NO INDICATOR, SUBMITTED
{
    $form->process( {
            foo => 'yada',
            bar => '23',
        } );

    ok( $form->submitted );
}

# NO INDICATOR, UNKNOWN PARAM, NOT SUBMITTED
{
    $form->process( { unknown => 1, } );

    ok( !$form->submitted );
}

# NAMED INDICATOR, SUBMITTED
{
    $form->indicator('foo');

    $form->process( {
            foo => 'yada',
            bar => '23',
        } );

    ok( $form->submitted );
}

# NAMED INDICATOR, UNKNOWN PARAM, NOT SUBMITTED
{
    $form->indicator('foo');

    $form->process( { unknown => 1, } );

    ok( !$form->submitted );
}

# CODE-REF INDICATOR, SUBMITTED
{
    $form->indicator( sub { return 1 } );

    $form->process( {} );

    ok( $form->submitted );
}
