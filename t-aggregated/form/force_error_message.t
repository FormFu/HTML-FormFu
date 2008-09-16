use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->form_error_message('Forced Error Message')->force_error_message(1);

my $field = $form->element('Text')->name('foo');

$field->constraint('Number');

$form->process( { foo => '1', } );

ok( !$form->has_errors );

my $xhtml = <<EOF;
<form action="" method="post">
<div class="form_error_message">Forced Error Message</div>
<div class="text">
<input name="foo" type="text" value="1" />
</div>
</form>
EOF

is( "$form", $xhtml );
