use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Select')->name('foo')->values( [qw/ one two three /] )
    ->default('two')->multiple(1);

$form->process( { foo => [qw/ one three /], } );

my $xhtml = <<EOF;
<form action="" method="post">
<span class="select">
<select name="foo" multiple="1">
<option value="one" selected="selected">One</option>
<option value="two">Two</option>
<option value="three" selected="selected">Three</option>
</select>
</span>
</form>
EOF

is( "$form", $xhtml );
