use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;
my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->element('Select')->name('foo');
$form->element('Select')->name('bar')->options();

my $xhtml = <<EOF;
<form action="" method="post">
<div>
<select name="foo">
</select>
</div>
<div>
<select name="bar">
</select>
</div>
</form>
EOF

eval { is( "$form", $xhtml ); };

ok( !$@, "died: $@" );
