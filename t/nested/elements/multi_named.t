use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->auto_fieldset( { nested_name => 'nested' } );

my $multi = $form->element('Multi')->name('foo');

$multi->element('Text')->name('bar');

my $form_xhtml = <<EOF;
<form action="" method="post">
<fieldset>
<div>
<span class="elements">
<input name="nested.foo.bar" type="text" />
</span>
</div>
</fieldset>
</form>
EOF

is( "$form", $form_xhtml, 'stringified form' );

$form->process( { 'nested.foo.bar' => 'aaa', } );

ok( $form->submitted_and_valid );

is( $form->param_value('nested.foo.bar'), 'aaa' );
