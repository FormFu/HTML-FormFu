use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t/elements/text_auto_comment_class.yml');

my $expected_form_xhtml = <<EOF;
<form action="" method="post">
<fieldset>
<div>
<input name="foo" type="text" />
<span>
Foo!
</span>
</div>
<div>
<input name="bar" type="text" />
<span class="formfu_bar_comment">
Bar!
</span>
</div>
</fieldset>
</form>
EOF

is( "$form", $expected_form_xhtml );
