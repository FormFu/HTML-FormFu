use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new->auto_fieldset( { id => 'fs' } );

$form->element('Text')->name('foo');
$form->element('Text')->name('bar');

my $fs = $form->element('Fieldset');

$fs->element('Text')->name('baz');

$form->element('Text')->name('yam');

# xhtml output

my $xhtml = <<EOF;
<form action="" method="post">
<fieldset id="fs">
<span class="text">
<input name="foo" type="text" />
</span>
<span class="text">
<input name="bar" type="text" />
</span>
</fieldset>
<fieldset>
<span class="text">
<input name="baz" type="text" />
</span>
<span class="text">
<input name="yam" type="text" />
</span>
</fieldset>
</form>
EOF

is( "$form", $xhtml );
