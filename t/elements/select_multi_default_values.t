use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

my $field = $form->element('Select')->name('foo')
    ->options( [ [ 1 => 'One' ], [ 2 => 'Two' ], [ 3 => 'Three' ] ] );

$form->default_values( { foo => [ 2, 3 ] } );

# correct options are rendered selected
{
    $form->process;

    like( "$form", qr/value="2" selected="selected"/ );
    like( "$form", qr/value="3" selected="selected"/ );
}
