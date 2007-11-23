use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

my $element = $form->element('File')->name('foo');

my $field_xhtml = qq{<span class="file">
<input name="foo" type="file" />
</span>};

is( "$element", $field_xhtml );

my $form_xhtml = <<EOF;
<form action="" enctype="multipart/form-data" method="post">
$field_xhtml
</form>
EOF

is( "$form", $form_xhtml );

