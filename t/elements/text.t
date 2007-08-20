use strict;
use warnings;

use Test::More tests => 9;

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

is( $element->render, $expected_field_xhtml );
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

ok( my $form_renderer = $form->render );
is( $form_renderer->output, $expected_form_xhtml );
is( "$form_renderer",       $expected_form_xhtml );
is( "$form",                $expected_form_xhtml );
