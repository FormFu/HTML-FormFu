use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->id('form')->auto_constraint_class('%t_constraint');

$form->element('Text')->name('foo');
$form->element('Text')->name('bar')->auto_constraint_class('%f_%t_c');

$form->constraint('Number');

is( $form->get_field('foo'),
    q{<div class="text number_constraint">
<input name="foo" type="text" />
</div>}
);

is( $form->get_field('bar'),
    q{<div class="text form_number_c">
<input name="bar" type="text" />
</div>}
);
