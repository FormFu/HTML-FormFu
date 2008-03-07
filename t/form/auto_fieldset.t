use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->auto_fieldset( { id => 'fs' } );

$form->element('Text')->name('foo');
$form->element('Text')->name('bar');

my $fs = $form->element('Fieldset');

$fs->element('Text')->name('baz');

$form->element('Text')->name('yam');

# xhtml output

my $xhtml = <<EOF;
<form action="" method="post">
<fieldset id="fs">
<div class="text">
<input name="foo" type="text" />
</div>
<div class="text">
<input name="bar" type="text" />
</div>
</fieldset>
<fieldset>
<div class="text">
<input name="baz" type="text" />
</div>
<div class="text">
<input name="yam" type="text" />
</div>
</fieldset>
</form>
EOF

is( "$form", $xhtml );
