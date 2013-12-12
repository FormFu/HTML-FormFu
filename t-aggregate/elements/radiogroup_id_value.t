use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;
use lib 't/lib';
use HTMLFormFu::TestLib;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->id('form')->auto_id('%n_%v');

$form->element('Radiogroup')->name('foo')->values( [qw( a b )] );
$form->element('Radiogroup')->name('foo')->values( [qw( c d )] );

my $form_xhtml = <<XHTML;
<form action="" id="form" method="post">
<fieldset>
<span>
<span>
<input name="foo" type="radio" value="a" id="foo_a" />
<label for="foo_a">A</label>
</span>
<span>
<input name="foo" type="radio" value="b" id="foo_b" />
<label for="foo_b">B</label>
</span>
</span>
</fieldset>
<fieldset>
<span>
<span>
<input name="foo" type="radio" value="c" id="foo_c" />
<label for="foo_c">C</label>
</span>
<span>
<input name="foo" type="radio" value="d" id="foo_d" />
<label for="foo_d">D</label>
</span>
</span>
</fieldset>
</form>
XHTML

is( "$form", $form_xhtml );

