use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t/elements/block_repeatable_auto_id.yml');

my $fs = $form->get_element;
my $block = $fs->get_element;

$block->repeat(2);

is( $form, <<HTML );
<form action="" method="post">
<fieldset>
<div>
<span class="text">
<input name="foo" type="text" id="foo_1" />
</span>
<span class="text">
<input name="bar" type="text" id="bar_1" />
</span>
</div>
<div>
<span class="text">
<input name="foo" type="text" id="foo_2" />
</span>
<span class="text">
<input name="bar" type="text" id="bar_2" />
</span>
</div>
<span class="submit">
<input name="submit" type="submit" />
</span>
</fieldset>
</form>
HTML
