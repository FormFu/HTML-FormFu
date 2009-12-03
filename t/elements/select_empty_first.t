use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t/elements/select_empty_first.yml');

$form->process;

is ( "$form", <<EOF );
<form action="" method="post">
<div class="select">
<select name="foo">
<option value=""></option>
<option value="1">One</option>
<option value="2">Two</option>
</select>
</div>
</form>
EOF
