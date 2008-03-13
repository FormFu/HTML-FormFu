use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t/elements/block_repeatable_tag.yml');

my $fs    = $form->get_element;
my $block = $fs->get_element;

$block->repeat(2);

is( $form, <<HTML );
<form action="" method="post">
<fieldset>
<fieldset>
<div class="text">
<input name="foo_1" type="text" />
</div>
<div class="text">
<input name="bar_1" type="text" />
</div>
</fieldset>
<fieldset>
<div class="text">
<input name="foo_2" type="text" />
</div>
<div class="text">
<input name="bar_2" type="text" />
</div>
</fieldset>
<div class="submit">
<input name="submit" type="submit" />
</div>
</fieldset>
</form>
HTML
