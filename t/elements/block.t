use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->auto_fieldset(1);

my $block = $form->element( {
        type    => 'Block',
        tag     => 'span',
        content => 'Hello <World>!',
    } );

$block->element( { name => "foo" } );

# because there's a content(), the block's elements should be ignored

my $block_xhtml = qq{<span>
Hello &lt;World&gt;!
</span>};

is( $block, $block_xhtml );

my $form_xhtml = <<EOF;
<form action="" method="post">
<fieldset>
$block_xhtml
</fieldset>
</form>
EOF

is( $form, $form_xhtml );

