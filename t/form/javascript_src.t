use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->auto_fieldset(1);
$form->javascript_src('/dojo.js');
$form->javascript('foo();');

my $xhtml = <<EOF;
<form action="" method="post">
<script type="text/javascript" src="/dojo.js">
</script>
<script type="text/javascript">
foo();
</script>
<fieldset>
</fieldset>
</form>
EOF

is( "$form", $xhtml );

# multiple
{
    $form->javascript_src( [qw{ /one.js /two.js }] );

    my $xhtml = <<EOF;
<form action="" method="post">
<script type="text/javascript" src="/one.js">
</script>
<script type="text/javascript" src="/two.js">
</script>
<script type="text/javascript">
foo();
</script>
<fieldset>
</fieldset>
</form>
EOF

    is( "$form", $xhtml );
}
