use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo')->inflator('DateTime')
    ->parser( { strptime => '%d/%m/%Y' } );

$form->process( { foo => "" } );

ok( $form->submitted_and_valid );

