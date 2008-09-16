use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

my $field = $form->element('Reset')->name('foo');

my $field_xhtml = qq{<div class="reset">
<input name="foo" type="reset" />
</div>};

is( "$field", $field_xhtml, 'stringified field' );

my $form_xhtml = <<EOF;
<form action="" method="post">
$field_xhtml
</form>
EOF

is( "$form", $form_xhtml, 'stringified form' );

