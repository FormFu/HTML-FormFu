use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t/elements/checkbox_reverse.yml');

my $form_xhtml = <<EOF;
<form action="" method="post">
<div class="checkbox label">
<label>Foo</label>
<input name="foo" type="checkbox" value="1" />
</div>
<div class="checkbox label">
<input name="bar" type="checkbox" value="1" />
<label>Bar</label>
</div>
</form>
EOF

is( $form, $form_xhtml );
