use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo');
$form->element('Textarea')->name('bar')->default("Bar\n");
$form->element('Textarea')->name('baz');

{
    my $xhtml = <<XHTML;
<form action="" method="post">
<span class="text">
<input name="foo" type="text" />
</span>
<span class="textarea">
<textarea name="bar" cols="40" rows="20">Bar
</textarea>
</span>
<span class="textarea">
<textarea name="baz" cols="40" rows="20"></textarea>
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
	<span class="textarea">
		<textarea name="bar" cols="40" rows="20">Bar
</textarea>
	</span>
	<span class="textarea">
		<textarea name="baz" cols="40" rows="20"></textarea>
	</span>
</form>
XHTML

    is( "$form", $xhtml );
}
