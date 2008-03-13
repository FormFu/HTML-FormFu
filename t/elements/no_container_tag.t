use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t/elements/no_container_tag.yml');

my $expected_form_xhtml = <<EOF;
<form action="" method="post">
<input name="foo" type="text" />
</form>
EOF

is( "$form", $expected_form_xhtml );
