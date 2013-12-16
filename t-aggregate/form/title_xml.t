use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->title_xml('My &amp; Form');

my $form_xhtml = <<EOF;
<form action="" method="post" title="My &amp; Form">
</form>
EOF

is( "$form", $form_xhtml );

