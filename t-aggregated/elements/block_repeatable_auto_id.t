use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t-aggregated/elements/block_repeatable_auto_id.yml');

my $fs    = $form->get_element;
my $block = $fs->get_element;

$block->repeat(2);

is( $form, <<HTML );
<form action="" method="post">
<fieldset>
<div>
<div class="text">
<input name="foo" type="text" id="foo_1" />
</div>
<div class="text">
<input name="bar" type="text" id="bar_1" />
</div>
</div>
<div>
<div class="text">
<input name="foo" type="text" id="foo_2" />
</div>
<div class="text">
<input name="bar" type="text" id="bar_2" />
</div>
</div>
<div class="submit">
<input name="submit" type="submit" />
</div>
</fieldset>
</form>
HTML
