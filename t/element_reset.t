use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $field = $form->element('reset')->name('foo');

my $field_xhtml = qq{<span class="reset">
<input name="foo" type="reset" />
</span>};

is( "$field", $field_xhtml, 'stringified field' );

my $form_xhtml = <<EOF;
<form action="" method="post">
$field_xhtml
</form>
EOF

is( "$form", $form_xhtml, 'stringified form' );

