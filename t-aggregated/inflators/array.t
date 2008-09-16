use strict;
use warnings;

use Test::More tests => 8;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $field = $form->element('Text')->name('foo');

$field->inflator('DateTime')->parser( { strptime => '%d/%m/%Y' } );

$form->process( {
    foo => [ '31/12/2006', '01/01/2007' ],
} );

my $value = $form->param_array('foo');

isa_ok( $value->[0], 'DateTime' );

is( $value->[0]->day, 31 );
is( $value->[0]->month, 12 );
is( $value->[0]->year, 2006 );

isa_ok( $value->[1], 'DateTime' );

is( $value->[1]->day, 1 );
is( $value->[1]->month, 1 );
is( $value->[1]->year, 2007 );
