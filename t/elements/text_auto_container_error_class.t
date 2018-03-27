use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t/elements/text_auto_container_error_class.yml');

$form->process( { submit => 'Submit', } );

my $expected_form_xhtml = <<EOF;
<form action="" method="post">
<fieldset>
<div>
<span>This field is required</span>
<input name="foo" type="text" />
</div>
<div class="formfu_error">
<span>This field is required</span>
<input name="bar" type="text" />
</div>
<div>
<input name="submit" type="submit" value="Submit" />
</div>
</fieldset>
</form>
EOF

is( "$form", $expected_form_xhtml );
