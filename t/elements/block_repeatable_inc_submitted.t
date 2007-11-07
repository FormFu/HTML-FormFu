use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new({ render_class_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t/elements/block_repeatable_inc.yml');

my $fs = $form->get_element;
my $block = $fs->get_element;

$block->repeat(2);

$form->process({
    foo1 => 'a',
    bar1 => 'b',
    foo2 => 'c',
    bar2 => 'd',
});

is_deeply(
    $form->params,
    {
        foo1 => 'a',
        bar1 => 'b',
        foo2 => 'c',
        bar2 => 'd',
    }
);

is( $form, <<HTML );
<form action="" method="post">
<fieldset>
<div>
<span class="text">
<input name="foo1" type="text" value="a" />
</span>
<span class="text">
<input name="bar1" type="text" value="b" />
</span>
</div>
<div>
<span class="text">
<input name="foo2" type="text" value="c" />
</span>
<span class="text">
<input name="bar2" type="text" value="d" />
</span>
</div>
<span class="submit">
<input name="submit" type="submit" />
</span>
</fieldset>
</form>
HTML
