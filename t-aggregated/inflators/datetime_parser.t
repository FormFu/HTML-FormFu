use strict;
use warnings;

use Test::More tests => 5;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo')->inflator('DateTime')
    ->parser( { strptime => '%d/%m/%Y' } );

$form->process( { foo => '31/12/2006' } );

ok( $form->submitted_and_valid );

my $value = $form->params->{foo};

isa_ok( $value, 'DateTime' );

is( $value->day,   31 );
is( $value->month, 12 );
is( $value->year,  2006 );
