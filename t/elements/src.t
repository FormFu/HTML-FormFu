use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->auto_fieldset(1);

my $block = $form->element( {
        type        => 'Src',
        content_xml => 'Hello <i>World</i>!',
    } );

my $block_xhtml = qq{
Hello <i>World</i>!
};

is( $block, $block_xhtml );

my $form_xhtml = <<EOF;
<form action="" method="post">
<fieldset>
$block_xhtml
</fieldset>
</form>
EOF

is( $form, $form_xhtml );

