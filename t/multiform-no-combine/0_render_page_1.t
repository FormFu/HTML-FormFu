use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu::MultiForm;

my $multi = HTML::FormFu::MultiForm->new;

$multi->load_config_file('t/multiform-no-combine/multiform.yml');

$multi->process;

my $html = <<HTML;
<form action="" id="form" method="post">
<fieldset>
<input name="crypt" type="hidden" />
<span class="text">
<input name="foo" type="text" />
</span>
<span class="submit">
<input name="submit" type="submit" />
</span>
</fieldset>
</form>
HTML

is( "$multi", $html );

my $form = $multi->current_form;

is( "$form", $html );
