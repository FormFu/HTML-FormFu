use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t/nested/elements/select_same_name.yml');

$form->process( { 'x.foo' => [ 1, 2 ], } );

is( "$form", <<EOF );
<form action="" method="post">
<fieldset>
<div>
<select name="x.foo">
<option value="1" selected="selected">One</option>
<option value="2">Two</option>
</select>
</div>
<div>
<select name="x.foo">
<option value="1">One</option>
<option value="2" selected="selected">Two</option>
</select>
</div>
</fieldset>
</form>
EOF
