use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new->form_error_message('Forced Error Message')
    ->force_error_message(1);

my $field = $form->element('Text')->name('foo');

$field->constraint('Number');

$form->process( { foo => '1', } );

ok( !$form->has_errors );

my $xhtml = <<EOF;
<form action="" method="post">
<div class="form_error_message">Forced Error Message</div>
<span class="text">
<input name="foo" type="text" value="1" />
</span>
</form>
EOF

is( "$form", $xhtml );
