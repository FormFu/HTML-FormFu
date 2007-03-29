use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;
my $form = HTML::FormFu->new;

$form->element('select')->name('foo');
$form->element('select')->name('bar')->options();

my $xhtml = <<EOF;
<form action="" method="post">
<span class="select">
<select name="foo">
</select>
</span>
<span class="select">
<select name="bar">
</select>
</span>
</form>
EOF

eval {
    is( "$form", $xhtml );
};

ok( !$@, "died: $@" );
