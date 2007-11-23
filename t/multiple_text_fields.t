use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo');
$form->element('Text')->name('foo');

$form->process( { foo => [qw/ a b /], } );

my $xhtml = <<EOF;
<form action="" method="post">
<span class="text">
<input name="foo" type="text" value="a" />
</span>
<span class="text">
<input name="foo" type="text" value="b" />
</span>
</form>
EOF

is( "$form", $xhtml );
