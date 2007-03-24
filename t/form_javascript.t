use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->auto_fieldset(1);
$form->javascript('foo();');

# xhtml output

my $xhtml = <<EOF;
<form action="" method="post">
<script type="text/javascript">
foo();
</script>
<fieldset>
</fieldset>
</form>
EOF

is( "$form", $xhtml );
