use strict;
use warnings;

use Test::More tests => 5;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t/elements/block_repeatable_inc.yml');

my $fs = $form->get_element;
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
<span class="text">
<input name="foo_1" type="text" />
</span>
<span class="text">
<input name="bar_1" type="text" />
</span>
</div>
<div>
<span class="text">
<input name="foo_2" type="text" />
</span>
<span class="text">
<input name="bar_2" type="text" />
</span>
</div>
<span class="submit">
<input name="submit" type="submit" />
</span>
</fieldset>
</form>
HTML
