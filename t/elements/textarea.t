use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

my $field = $form->element('Textarea')->name('foo');

# add more elements to test accessor output
$form->element('Textarea')->name('bar')->default("foo\nbar")->cols(10)->rows(2);

my $field_xhtml = qq{<div class="textarea">
<textarea name="foo" cols="40" rows="20"></textarea>
</div>};

is( "$field", $field_xhtml );

my $form_xhtml = <<EOF;
<form action="" method="post">
$field_xhtml
<div class="textarea">
<textarea name="bar" cols="10" rows="2">foo
bar</textarea>
</div>
</form>
EOF

is( "$form", $form_xhtml, 'stringified form' );

