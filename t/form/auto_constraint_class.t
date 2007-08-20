use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form
    = HTML::FormFu->new->id('form')->auto_constraint_class('%t_constraint');

$form->element('Text')->name('foo');
$form->element('Text')->name('bar')->auto_constraint_class('%f_%t_c');

$form->constraint('Number');

like( $form->get_field('foo'), qr!\bnumber_constraint\b! );

like( $form->get_field('bar'), qr!\bform_number_c\b! );
