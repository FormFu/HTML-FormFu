use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Select')->name('foo')->values( [qw/ one two three /] )
    ->default('two')->multiple(1);

$form->process( { foo => [qw/ one three /], } );

my $xhtml = <<EOF;
<form action="" method="post">
<div class="select">
<select name="foo" multiple="1">
<option value="one" selected="selected">One</option>
<option value="two">Two</option>
<option value="three" selected="selected">Three</option>
</select>
</div>
</form>
EOF

is( "$form", $xhtml );

$form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Select')->name('foo')->values( [qw/ one two three /] )
    ->default('two')->multiple(1);
my $select_field = $form->get_element( { name => 'foo' } );
$select_field->default( [qw/ one three /] );
is( "$form", $xhtml );

