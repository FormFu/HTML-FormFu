use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $field = $form->element('textarea')->name('foo');

# add more elements to test accessor output
$form->element('textarea')->name('bar')->default("foo\nbar")->cols(10)->rows(2);

my $field_xhtml = qq{<span class="textarea">
<textarea name="foo" cols="40" rows="20"></textarea>
</span>};

is( "$field", $field_xhtml );

my $form_xhtml = <<EOF;
<form action="" method="post">
$field_xhtml
<span class="textarea">
<textarea name="bar" cols="10" rows="2">foo
bar</textarea>
</span>
</form>
EOF

is( "$form", $form_xhtml, 'stringified form' );

