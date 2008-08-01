use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo');

$form->inflator('DateTime')->parser( {
        regex  => '^(\d{2})\/(\d{2})\/(\d{4})$',
        params => [qw/ month day year /],
    } );

$form->process( { foo => '12/31/2006' } );

ok( !$form->has_errors );

my $value = $form->params->{foo};

is( $value->day,   31 );
is( $value->month, 12 );
is( $value->year,  2006 );
