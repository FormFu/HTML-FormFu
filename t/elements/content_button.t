use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $field = $form->element('content_button')->name('foo');

# add more elements to test accessor output
$form->element('content_button')->name('bar')->content('<p>button</p>');
$form->element('content_button')->name('baz')->content('x')->field_type('submit');
$form->element('content_button')->name('baf')->field_type('reset');

my $field_xhtml = qq{<span class="content_button">
<button name="foo" type="button"></button>
</span>};

is( "$field", $field_xhtml, 'stringified field' );

my $form_xhtml = <<EOF;
<form action="" method="post">
$field_xhtml
<span class="content_button">
<button name="bar" type="button"><p>button</p></button>
</span>
<span class="content_button">
<button name="baz" type="submit">x</button>
</span>
<span class="content_button">
<button name="baf" type="reset"></button>
</span>
</form>
EOF

is( "$form", $form_xhtml, 'stringified form' );

