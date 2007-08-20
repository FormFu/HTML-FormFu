use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Radiogroup')->name('foo')->values( [qw/ one two three /] )
    ->default('two');

$form->process( { foo => [qw/ one three /], } );

my $xhtml = <<EOF;
<form action="" method="post">
<fieldset class="radiogroup">
<span>
<span>
<input name="foo" type="radio" value="one" checked="checked" />
<label>One</label>
</span>
<span>
<input name="foo" type="radio" value="two" />
<label>Two</label>
</span>
<span>
<input name="foo" type="radio" value="three" checked="checked" />
<label>Three</label>
</span>
</span>
</fieldset>
</form>
EOF

is( "$form", $xhtml );
