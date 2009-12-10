use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t/elements/repeatable_repeatable.yml');

$form->process({
    count => 2,
    foo_1 => 'a',
    foo_2 => 'b',
    count_1 => 1,
    foo_1_1 => 'c',
    bar_1_1 => 'd',
    count_2 => 2,
    foo_2_1 => 'e',
    foo_2_2 => 'f',
    bar_2_1 => 'g',
    bar_2_2 => 'h',
});

ok( $form->submitted_and_valid );

is( "$form", <<HTML );
<form action="" method="post">
<fieldset>
<input name="count" type="hidden" value="2" />
<div>
<div class="text">
<input name="foo_1" type="text" value="a" />
</div>
<input name="count_1" type="hidden" value="1" />
<div>
<div class="text">
<input name="foo_1_1" type="text" value="c" />
</div>
<div class="text">
<input name="bar_1_1" type="text" value="d" />
</div>
</div>
</div>
<div>
<div class="text">
<input name="foo_2" type="text" value="b" />
</div>
<input name="count_2" type="hidden" value="2" />
<div>
<div class="text">
<input name="foo_2_1" type="text" value="e" />
</div>
<div class="text">
<input name="bar_2_1" type="text" value="g" />
</div>
</div>
<div>
<div class="text">
<input name="foo_2_2" type="text" value="f" />
</div>
<div class="text">
<input name="bar_2_2" type="text" value="h" />
</div>
</div>
</div>
</fieldset>
</form>
HTML
