use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Date')->name('foo')->auto_inflate(1);

# empty input

$form->process( { 'foo_day', '', 'foo_month', '', 'foo_year', '', } );

ok( $form->submitted_and_valid );

