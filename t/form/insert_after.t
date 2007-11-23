use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

my $e1 = $form->element('Text')->name('foo');
my $e2 = $form->element('Hidden')->name('foo');

my $e3 = $e1->clone;

$form->insert_after( $e3, $e1 );

my $elems = $form->get_elements;

is( $elems->[0], $e1 );
is( $elems->[1], $e3 );
is( $elems->[2], $e2 );
