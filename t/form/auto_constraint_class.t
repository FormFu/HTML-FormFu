use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new( { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->id('form')->auto_constraint_class('%t_constraint');

$form->element('Text')->name('foo');
$form->element('Text')->name('bar')->auto_constraint_class('%f_%t_c');

$form->constraint('Number');

is( $form->get_field('foo'),
    q{<span class="text number_constraint">
<input name="foo" type="text" />
</span>}
);

is( $form->get_field('bar'),
    q{<span class="text form_number_c">
<input name="bar" type="text" />
</span>}
);
