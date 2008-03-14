use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $e1 = $form->element('Text')->name('foo');
my $e2 = $form->element('Hidden')->name('foo');

my $e3 = $e1->clone;

$form->insert_after( $e3, $e1 );

my $elems = $form->get_elements;

ok( $elems->[0] == $e1 );
ok( $elems->[1] == $e3 );
ok( $elems->[2] == $e2 );
