use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo')->inflator('DateTime')
    ->parser( { strptime => '%d/%m/%Y' } );

$form->process( { foo => '31/12/2006' } );

my $value = $form->params->{foo};

is( $value->day,   31 );
is( $value->month, 12 );
is( $value->year,  2006 );
