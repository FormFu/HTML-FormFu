use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;
use lib 't/lib';

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t/roles/block.yml');

my $expected_form_xhtml = <<EOF;
<form action="" method="post">
<div class="myblockrole">
<div>
<input name="foo" type="text" />
</div>
</div>
</form>
EOF

is( "$form", $expected_form_xhtml );
