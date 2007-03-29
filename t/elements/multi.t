use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $multi = $form->element('multi')->label('My multi');

$multi->element('text')->name('bar')->label('My text');
$multi->element('hidden')->name('baz');
$multi->element('radio')->name('dot')->label('My radio');

my $form_xhtml = <<EOF;
<form action="" method="post">
<span class="multi label">
<label>My multi</label>
<span class="elements">
<label>My text</label>
<input name="bar" type="text" />
<input name="baz" type="hidden" />
<input name="dot" type="radio" />
<label>My radio</label>
</span>
</span>
</form>
EOF

is( "$form", $form_xhtml, 'stringified form' );

