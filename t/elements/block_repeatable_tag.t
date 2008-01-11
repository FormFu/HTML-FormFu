use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t/elements/block_repeatable_tag.yml');

my $fs = $form->get_element;
my $block = $fs->get_element;

$block->repeat(2);

is( $form, <<HTML );
<form action="" method="post">
<fieldset>
<fieldset>
<span class="text">
<input name="foo_1" type="text" />
</span>
<span class="text">
<input name="bar_1" type="text" />
</span>
</fieldset>
<fieldset>
<span class="text">
<input name="foo_2" type="text" />
</span>
<span class="text">
<input name="bar_2" type="text" />
</span>
</fieldset>
<span class="submit">
<input name="submit" type="submit" />
</span>
</fieldset>
</form>
HTML
