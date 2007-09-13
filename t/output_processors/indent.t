use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo');

{
    my $xhtml = <<XHTML;
<form action="" method="post">
<span class="text">
<input name="foo" type="text" />
</span>
</form>
XHTML

    is( "$form", $xhtml );
}

$form->output_processor('Indent');

{
    my $xhtml = <<XHTML;
<form action="" method="post">
	<span class="text">
		<input name="foo" type="text" />
	</span>
</form>
XHTML

    is( "$form", $xhtml );
}
