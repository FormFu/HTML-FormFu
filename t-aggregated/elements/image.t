use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

my $field = $form->element('Image')->name('foo');

# add more elements to test accessor output
$form->element('Image')->name('bar')->src('foo.jpg');
$form->element('Image')->name('baz')->src('/bar')->width(120)->height(32);

my $field_xhtml = qq{<div class="image">
<input name="foo" type="image" src="" />
</div>};

is( "$field", $field_xhtml, 'stringified field' );

my $form_xhtml = <<EOF;
<form action="" method="post">
$field_xhtml
<div class="image">
<input name="bar" type="image" src="foo.jpg" />
</div>
<div class="image">
<input name="baz" type="image" height="32" src="/bar" width="120" />
</div>
</form>
EOF

is( "$form", $form_xhtml, 'stringified form' );

