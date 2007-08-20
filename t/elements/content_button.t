use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $field = $form->element('ContentButton')->name('foo');

# add more elements to test accessor output
$form->element('ContentButton')->name('bar')->content_xml('<p>button</p>');
$form->element('ContentButton')->name('baz')->content('x')
    ->field_type('submit');
$form->element('ContentButton')->name('baf')->field_type('reset');

my $field_xhtml = qq{<span class="contentbutton">
<button name="foo" type="button"></button>
</span>};

is( "$field", $field_xhtml, 'stringified field' );

my $form_xhtml = <<EOF;
<form action="" method="post">
$field_xhtml
<span class="contentbutton">
<button name="bar" type="button"><p>button</p></button>
</span>
<span class="contentbutton">
<button name="baz" type="submit">x</button>
</span>
<span class="contentbutton">
<button name="baf" type="reset"></button>
</span>
</form>
EOF

is( "$form", $form_xhtml, 'stringified form' );

