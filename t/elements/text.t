use strict;
use warnings;

use Test::More tests => 5;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

ok( my $element = $form->element('Text')->name('foo') );
is( $element->name, 'foo' );
is( $element->type, 'Text' );

# add more elements to test accessor output
$form->element('Text')->name('bar')->size(10);
$form->element('Text')->name('baz')->size(15)->maxlength(20);

my $expected_field_xhtml = qq{<div>
<input name="foo" type="text" />
</div>};

is( "$element", $expected_field_xhtml );

my $expected_form_xhtml = <<EOF;
<form action="" method="post">
$expected_field_xhtml
<div>
<input name="bar" type="text" size="10" />
</div>
<div>
<input name="baz" type="text" maxlength="20" size="15" />
</div>
</form>
EOF

is( "$form", $expected_form_xhtml );
