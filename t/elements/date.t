use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $element = $form->element('date')->name('foo');

$element->constraint('Required');

$form->process({
    'foo.day', 30,
    'foo.month', 6,
    'foo.year', 2007,
    });

is( $form->params->{foo}, "30-06-2007" );
