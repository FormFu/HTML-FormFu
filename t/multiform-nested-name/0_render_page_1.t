use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu::MultiForm;

my $multi = HTML::FormFu::MultiForm->new;

$multi->load_config_file('t/multiform-nested-name/multiform.yml');

$multi->process;

my $html = <<HTML;
<form action="" id="form" method="post">
<fieldset>
<span class="text">
<input name="foo" type="text" />
</span>
<div>
<span class="text">
<input name="block.foo" type="text" />
</span>
</div>
<span class="submit">
<input name="submit" type="submit" />
</span>
</fieldset>
</form>
HTML

is( "$multi", $html );

my $form = $multi->current_form;

is( "$form", $html );
