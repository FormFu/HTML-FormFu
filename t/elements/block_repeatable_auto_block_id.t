use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t/elements/block_repeatable_auto_block_id.yml');

my $repeatable = $form->get_element;

$repeatable->repeat(2);

is( $form, <<HTML );
<form action="" method="post">
<div>
<span id="inner_1">
<div class="text">
<input name="foo_1" type="text" />
</div>
<div class="text">
<input name="bar_1" type="text" />
</div>
</span>
</div>
<div>
<span id="inner_2">
<div class="text">
<input name="foo_2" type="text" />
</div>
<div class="text">
<input name="bar_2" type="text" />
</div>
</span>
</div>
</form>
HTML
