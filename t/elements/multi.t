use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $multi = $form->element('Multi')->label('My multi');

$multi->element('Text')->name('bar')->label('My text');
$multi->element('Hidden')->name('baz');
$multi->element('Radio')->name('dot')->label('My radio');
$multi->element('Blank')->name('gzz');

$form->element({ type => 'Submit' });

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
<span class="submit">
<input type="submit" />
</span>
</form>
EOF

is( "$form", $form_xhtml, 'stringified form' );

