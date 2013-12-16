use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new( {
    tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' },
} );

$form->load_config_file('t-aggregate/elements/text_datalist_values.yml');

my $expected_form_xhtml = <<EOF;
<form action="" id="form" method="post">
<div class="text">
<datalist id="form_foo_datalist">
<option value="one">One</option>
<option value="two">Two</option>
<option value="three">Three</option>
</datalist>
<input name="foo" type="text" id="form_foo" list="form_foo_datalist" />
</div>
</form>
EOF

is( "$form", $expected_form_xhtml );
