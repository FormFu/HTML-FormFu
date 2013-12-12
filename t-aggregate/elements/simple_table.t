use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );
$form->load_config_file('t-aggregate/elements/simple_table.yml');

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
<div>
<input name="foo" type="text" />
</div>
</td>
<td>
<div>
<input name="bar" type="text" />
</div>
</td>
</tr>
<tr>
<td>
<div>
<input name="foo" type="radio" value="1" />
</div>
</td>
<td>
<div>
<input name="bar" type="radio" value="1" />
</div>
</td>
</tr>
</table>
</fieldset>
</form>
EOF

is( "$form", $xhtml );

