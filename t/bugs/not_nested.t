use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->auto_fieldset(1);

my $field = $form->element('Text')->name('foo');

ok( !$field->nested );
