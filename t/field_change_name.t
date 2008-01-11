use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo')->constraint('Required');

ok( $form->get_constraint('foo') );

$form->get_field('foo')->name('bar');

ok( $form->get_constraint('bar') );
