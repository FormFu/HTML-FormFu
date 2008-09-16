use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t-aggregated/deflators/compoundsplit_split.yml');

$form->default_values({
    sortcode => '01-02-03',
});

$form->process;

my $html = <<HTML;
<form action="" method="post">
<div class="multi">
<span class="elements">
<input name="sortcode.p1" type="text" value="01" />
<input name="sortcode.p2" type="text" value="02" />
<input name="sortcode.p3" type="text" value="03" />
</span>
</div>
</form>
HTML

is( "$form", $html );
