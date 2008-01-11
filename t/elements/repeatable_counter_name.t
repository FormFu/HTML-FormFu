use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t/elements/repeatable_counter_name.yml');

my $fs = $form->get_element;
my $block = $fs->get_element;

# we don't call repeat() ourselves
# this should happen in $form->process()

$form->process({
    foo_1  => 'a',
    bar_1  => 'b',
    foo_2  => 'c',
    bar_2  => 'd',
    count => 2,
});

is_deeply(
    $form->params,
    {
        foo_1 => 'a',
        bar_1 => 'b',
        foo_2 => 'c',
        bar_2 => 'd',
    }
);

is( $form, <<HTML );
<form action="" method="post">
<fieldset>
<div>
<span class="text">
<input name="foo_1" type="text" value="a" />
</span>
<span class="text">
<input name="bar_1" type="text" value="b" />
</span>
</div>
<div>
<span class="text">
<input name="foo_2" type="text" value="c" />
</span>
<span class="text">
<input name="bar_2" type="text" value="d" />
</span>
</div>
<span class="submit">
<input name="submit" type="submit" />
</span>
</fieldset>
</form>
HTML
