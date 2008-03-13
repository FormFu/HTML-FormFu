use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

my $field = $form->element('ContentButton')->name('foo');

# add more elements to test accessor output
$form->element('ContentButton')->name('bar')->content_xml('<p>button</p>');
$form->element('ContentButton')->name('baz')->content('x')
    ->field_type('submit');
$form->element('ContentButton')->name('baf')->field_type('reset');

my $field_xhtml = qq{<div class="contentbutton">
<button name="foo" type="button"></button>
</div>};

is( "$field", $field_xhtml, 'stringified field' );

my $form_xhtml = <<EOF;
<form action="" method="post">
$field_xhtml
<div class="contentbutton">
<button name="bar" type="button"><p>button</p></button>
</div>
<div class="contentbutton">
<button name="baz" type="submit">x</button>
</div>
<div class="contentbutton">
<button name="baf" type="reset"></button>
</div>
</form>
EOF

is( "$form", $form_xhtml, 'stringified form' );

