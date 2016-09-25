use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t/elements/text_auto_container_class.yml');

my $expected_form_xhtml = <<EOF;
<form action="" method="post">
<fieldset>
<div>
<input name="foo" type="text" />
</div>
<div class="formfu_bar_text">
<input name="bar" type="text" />
</div>
</fieldset>
</form>
EOF

is( "$form", $expected_form_xhtml );
