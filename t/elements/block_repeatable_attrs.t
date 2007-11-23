use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t/elements/block_repeatable_attrs.yml');

my $fs = $form->get_element;
my $block = $fs->get_element;

$block->repeat(2);

is( $form, <<HTML );
<form action="" method="post">
<fieldset>
<div class="repeat">
<span class="text">
<input name="foo" type="text" />
</span>
<span class="text">
<input name="bar" type="text" />
</span>
</div>
<div class="repeat">
<span class="text">
<input name="foo" type="text" />
</span>
<span class="text">
<input name="bar" type="text" />
</span>
</div>
<span class="submit">
<input name="submit" type="submit" />
</span>
</fieldset>
</form>
HTML
