use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->auto_fieldset( { nested_name => 'text' } );

my $element = $form->element('Text')->name('foo');

is ( "$form", <<EOF );
<form action="" method="post">
<fieldset>
<span class="text">
<input name="text.foo" type="text" />
</span>
</fieldset>
</form>
EOF

$form->process({
    "text.foo" => 42,
});

is( $form->param('text.foo'), 42 );

is ( "$form", <<EOF );
<form action="" method="post">
<fieldset>
<span class="text">
<input name="text.foo" type="text" value="42" />
</span>
</fieldset>
</form>
EOF

