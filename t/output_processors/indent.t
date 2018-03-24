use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->element('Text')->name('foo');
$form->element('Textarea')->name('bar')->default("Bar\n");
$form->element('Textarea')->name('baz');

{
    my $xhtml = <<XHTML;
<form action="" method="post">
<div>
<input name="foo" type="text" />
</div>
<div>
<textarea name="bar" cols="40" rows="20">Bar
</textarea>
</div>
<div>
<textarea name="baz" cols="40" rows="20"></textarea>
</div>
</form>
XHTML

    is( "$form", $xhtml );
}

$form->output_processor('Indent');

{
    my $xhtml = <<"XHTML";
<form action="" method="post">
\t<div>
\t\t<input name="foo" type="text" />
\t</div>
\t<div>
\t\t<textarea name="bar" cols="40" rows="20">Bar
</textarea>
\t</div>
\t<div>
\t\t<textarea name="baz" cols="40" rows="20"></textarea>
\t</div>
</form>
XHTML

    is( "$form", $xhtml );
}
