use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $field = $form->element('Select')->name('foo')
    ->options( [ [ 1 => 'One' ], [ 2 => 'Two' ], [ 3 => 'Three' ] ] );

$field->default( [ 2, 3 ] );

# correct options are rendered selected
{
    $form->process;

    like( "$form", qr/value="2" selected="selected"/ );
    like( "$form", qr/value="3" selected="selected"/ );
}

# multi submit
{
    $form->process( { foo => [ 1, 3 ], } );

    ok( $form->submitted_and_valid );

    is_deeply( $form->param_array('foo'), [ 1, 3 ], );
}
