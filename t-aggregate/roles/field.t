use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;
use lib 't/lib';

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t-aggregate/roles/field.yml');

my $expected_form_xhtml = <<EOF;
<form action="" method="post">
<fieldset>
<div class="myfieldrole text">
<input name="foo" type="text" />
</div>
</fieldset>
</form>
EOF

is( "$form", $expected_form_xhtml );
