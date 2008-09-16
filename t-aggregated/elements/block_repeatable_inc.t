use strict;
use warnings;

use Test::More tests => 5;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t-aggregated/elements/block_repeatable_inc.yml');

my $fs    = $form->get_element;
my $block = $fs->get_element;

$block->repeat(2);

is( $form->get_field('foo_1')->original_name, 'foo' );
is( $form->get_field('bar_1')->original_name, 'bar' );
is( $form->get_field('foo_2')->original_name, 'foo' );
is( $form->get_field('bar_2')->original_name, 'bar' );

is( $form, <<HTML );
<form action="" method="post">
<fieldset>
<div>
<div class="text">
<input name="foo_1" type="text" />
</div>
<div class="text">
<input name="bar_1" type="text" />
</div>
</div>
<div>
<div class="text">
<input name="foo_2" type="text" />
</div>
<div class="text">
<input name="bar_2" type="text" />
</div>
</div>
<div class="submit">
<input name="submit" type="submit" />
</div>
</fieldset>
</form>
HTML
