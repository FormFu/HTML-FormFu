use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo')->inflator('DateTime')
    ->parser( { strptime => '%d/%m/%Y' } )->strptime('%d/%m/%Y');

$form->element('Text')->name('bar')->inflator('DateTime')
    ->parser( { strptime => '%d/%m/%Y' } )
    ->strptime( { pattern => '%m-%d-%Y' } );

$form->process( {
        foo => '31/12/2006',
        bar => '1/07/2007',
    } );

is( $form->params->{foo}, "31/12/2006" );
is( $form->params->{bar}, "07-01-2007" );
