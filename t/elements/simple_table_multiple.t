use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });
$form->load_config_file('t/elements/simple_table_multiple.yml');

# test putting an array-ref of elements into a single cell

my $xhtml = <<EOF;
<form action="" method="post">
<fieldset>
<table class="simpletable">
<tr>
<th>
foo
</th>
<th>
bar
</th>
</tr>
<tr>
<td>
<div class="text">
<input name="foo" type="text" />
</div>
<div class="radio">
<input name="foo" type="radio" />
</div>
</td>
<td>
<div class="text">
<input name="bar" type="text" />
</div>
<div class="radio">
<input name="bar" type="radio" />
</div>
</td>
</tr>
</table>
</fieldset>
</form>
EOF

is( "$form", $xhtml );

