use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->auto_fieldset( { nested_name => 'text' } );

my $element = $form->element('Text')->name('foo');

is( "$form", <<EOF );
<form action="" method="post">
<fieldset>
<div>
<input name="text.foo" type="text" />
</div>
</fieldset>
</form>
EOF

$form->process( { "text.foo" => 42, } );

is( $form->param('text.foo'), 42 );

is( "$form", <<EOF );
<form action="" method="post">
<fieldset>
<div>
<input name="text.foo" type="text" value="42" />
</div>
</fieldset>
</form>
EOF

