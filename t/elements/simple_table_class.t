use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );
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
<div>
<input name="foo" type="text" />
</div>
</td>
</tr>
<tr class="y">
<td>
<div>
<input name="bar" type="text" />
</div>
</td>
</tr>
<tr class="x">
<td>
<div>
<input name="baz" type="text" />
</div>
</td>
</tr>
</table>
</fieldset>
</form>
EOF

is( "$form", $xhtml );

