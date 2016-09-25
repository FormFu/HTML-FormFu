use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->form_error_message('Errors!');
$form->form_error_message_class('x-class');

my $field = $form->element('Text')->name('foo');

$field->constraint('Number');

$form->process( { foo => 'a', } );

like( "$form", qr{\Q<div class="x-class">Errors!</div>} );
