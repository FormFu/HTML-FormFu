use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t/elements/text_auto_label_class.yml');

my $expected_form_xhtml = <<EOF;
<form action="" method="post">
<fieldset>
<div>
<label>foo</label>
<input name="foo" type="text" />
</div>
<div>
<label class="text_label">bar</label>
<input name="bar" type="text" />
</div>
</fieldset>
</form>
EOF

is( "$form", $expected_form_xhtml );
