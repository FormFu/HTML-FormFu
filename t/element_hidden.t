use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $field = $form->element('hidden')->name('foo');


my $field_xhtml = qq{<input name="foo" type="hidden" />};

is( "$field", $field_xhtml );

my $form_xhtml = <<EOF;
<form action="" method="post">
$field_xhtml
</form>
EOF

is( "$form", $form_xhtml );

