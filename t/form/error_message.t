use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->form_error_message_loc('form_error_message');

my $field = $form->element('Text');

$field->name('foo');

$field->constraint('Number');

unlike( "$form", qr/there were errors/i );

$form->process( { foo => '1', } );

unlike( "$form", qr/there were errors/i );

$form->process( { foo => 'a', } );

my $xhtml = <<EOF;
<form action="" method="post">
<div class="form_error_message">There were errors with your submission, see below for details</div>
<span class="text error error_constraint_number">
<span class="error_message error_constraint_number">This field must be a number</span>
<input name="foo" type="text" value="a" />
</span>
</form>
EOF

is( "$form", $xhtml );
