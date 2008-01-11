use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t/elements/no_block_tag.yml');

my $expected_form_xhtml = <<EOF;
<form action="" method="post">

<span class="text">
<input name="foo" type="text" />
</span>

</form>
EOF

is( "$form", $expected_form_xhtml );
