use strict;
use warnings;

use Test::More tests => 5;

use HTML::FormFu;

my $form = HTML::FormFu->new;

ok( my $element = $form->element('Text')->name('foo') );
is( $element->name, 'foo' );
is( $element->type, 'Text' );

# add more elements to test accessor output
$form->element('Text')->name('bar')->size(10);
$form->element('Text')->name('baz')->size(15)->maxlength(20);

my $expected_field_xhtml = qq{<span class="text">
<input name="foo" type="text" />
</span>};

is( "$element", $expected_field_xhtml );

my $expected_form_xhtml = <<EOF;
<form action="" method="post">
$expected_field_xhtml
<span class="text">
<input name="bar" type="text" size="10" />
</span>
<span class="text">
<input name="baz" type="text" maxlength="20" size="15" />
</span>
</form>
EOF

is( "$form", $expected_form_xhtml );
