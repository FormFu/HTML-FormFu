use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $field = $form->element('image')->name('foo');

# add more elements to test accessor output
$form->element('image')->name('bar')->src('foo.jpg');
$form->element('image')->name('baz')->src('/bar')->width(120)->height(32);

my $field_xhtml = qq{<span class="image">
<input name="foo" type="image" src="" />
</span>};

is( "$field", $field_xhtml, 'stringified field' );

my $form_xhtml = <<EOF;
<form action="" method="post">
$field_xhtml
<span class="image">
<input name="bar" type="image" src="foo.jpg" />
</span>
<span class="image">
<input name="baz" type="image" height="32" src="/bar" width="120" />
</span>
</form>
EOF

is( "$form", $form_xhtml, 'stringified form' );

