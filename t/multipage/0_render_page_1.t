use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu::MultiPage;

my $multi = HTML::FormFu::MultiPage->new;

$multi->load_config_file('t/multipage/multipage.yml');

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
