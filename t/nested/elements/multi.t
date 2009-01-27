use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->auto_fieldset( { nested_name => 'nested' } );

my $multi = $form->element('Multi');

$multi->element('Text')->name('foo');

my $form_xhtml = <<EOF;
<form action="" method="post">
<fieldset>
<div class="multi">
<span class="elements">
<input name="nested.foo" type="text" />
</span>
</div>
</fieldset>
</form>
EOF

is( "$form", $form_xhtml, 'stringified form' );

