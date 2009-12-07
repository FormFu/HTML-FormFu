use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t/elements/block_auto_block_id.yml');

is( "$form", <<EOF );
<form action="" id="form" method="post">
<div id="form_block">
Hello
</div>
</form>
EOF
