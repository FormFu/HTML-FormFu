use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;
$form->load_config_file('t/elements/simple_table_class.yml');

my $xhtml = <<EOF;
<form action="" method="post">
<fieldset>
<table class="simpletable">
<tr>
<th>
foo
</th>
</tr>
<tr class="x">
<td>
<span class="text">
<input name="foo" type="text" />
</span>
</td>
</tr>
<tr class="y">
<td>
<span class="text">
<input name="bar" type="text" />
</span>
</td>
</tr>
<tr class="x">
<td>
<span class="text">
<input name="baz" type="text" />
</span>
</td>
</tr>
</table>
</fieldset>
</form>
EOF

is( "$form", $xhtml );

