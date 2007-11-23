use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo');

$form->element('Checkbox')->name('bar')->value('y');

$form->default_values({
    foo => 'x',
    bar => 'y',
});

$form->process;

like( $form->get_field('foo'), qr/value="x"/ );

like( $form->get_field('bar'), qr/value="y"/ );
like( $form->get_field('bar'), qr/checked="checked"/ );
