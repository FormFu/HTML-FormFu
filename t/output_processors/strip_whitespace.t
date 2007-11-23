use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t/output_processors/strip_whitespace.yml');

{
    my $xhtml = <<XHTML;
<form action="" method="post">
<fieldset>
<legend>fieldset</legend>
<input name="hidden" type="hidden" value="1" />
<span class="text label">
<label>Foo</label>
<input name="foo" type="text" />
</span>
<span class="textarea">
<textarea name="textarea" cols="40" rows="20">foo
bar
</textarea>
</span>
<span class="select">
<select name="select">
<option value="a">A</option>
<option value="b">B</option>
<option value="d">D</option>
</select>
</span>
<span class="select">
<select name="select2">
<option value="1">one</option>
<optgroup>
<option value="2">two</option>
<option value="3">three</option>
</optgroup>
</select>
</span>
<span class="multi">
<span class="elements">
<input name="multi1" type="text" />
<input name="multi2" type="text" />
</span>
</span>
<fieldset class="radiogroup">
<span>
<span>
<input name="radiogroup" type="radio" value="a" />
<label>A</label>
</span>
<span>
<input name="radiogroup" type="radio" value="b" />
<label>B</label>
</span>
<span>
<input name="radiogroup" type="radio" value="c" />
<label>C</label>
</span>
</span>
</fieldset>
<fieldset class="radiogroup">
<span>
<span>
<input name="radiogroup2" type="radio" value="1" />
<label>one</label>
</span>
<span class="subgroup">
<span>
<input name="radiogroup2" type="radio" value="2" />
<label>two</label>
</span>
<span>
<input name="radiogroup2" type="radio" value="3" />
<label>three</label>
</span>
</span>
</span>
</fieldset>
<span class="radio">
<input name="radio" type="radio" />
</span>
<table class="simpletable">
<tr>
<th>
foo
</th>
<th>
bar
</th>
</tr>
<tr>
<td>
<span class="text">
<input name="table1" type="text" />
</span>
</td>
<td>
<div>
foo
</div>
</td>
</tr>
<tr>
<td>
<span class="text">
<input name="table2" type="text" />
</span>
</td>
<td>
<div>
bar
</div>
</td>
</tr>
</table>
<hr />
<span class="submit">
<input name="submit" type="submit" />
</span>
</fieldset>
</form>
XHTML

    is( "$form", $xhtml );
}

$form->output_processor('StripWhitespace');

{
    my $xhtml
        = qq{<form action="" method="post"><fieldset><legend>fieldset</legend><input name="hidden" type="hidden" value="1" />
<span class="text label">
<label>Foo</label>
<input name="foo" type="text" />
</span><span class="textarea">
<textarea name="textarea" cols="40" rows="20">foo
bar
</textarea>
</span><span class="select">
<select name="select"><option value="a">A</option><option value="b">B</option><option value="d">D</option></select>
</span><span class="select">
<select name="select2"><option value="1">one</option><optgroup><option value="2">two</option><option value="3">three</option></optgroup></select>
</span><span class="multi"><span class="elements">
<input name="multi1" type="text" />
<input name="multi2" type="text" />
</span></span><fieldset class="radiogroup"><span><span>
<input name="radiogroup" type="radio" value="a" />
<label>A</label>
</span><span>
<input name="radiogroup" type="radio" value="b" />
<label>B</label>
</span><span>
<input name="radiogroup" type="radio" value="c" />
<label>C</label>
</span></span></fieldset><fieldset class="radiogroup"><span><span>
<input name="radiogroup2" type="radio" value="1" />
<label>one</label>
</span><span class="subgroup"><span>
<input name="radiogroup2" type="radio" value="2" />
<label>two</label>
</span><span>
<input name="radiogroup2" type="radio" value="3" />
<label>three</label>
</span></span></span></fieldset><span class="radio">
<input name="radio" type="radio" />
</span><table class="simpletable"><tr><th>foo</th><th>bar</th></tr><tr><td><span class="text">
<input name="table1" type="text" />
</span></td><td><div>
foo
</div></td></tr><tr><td><span class="text">
<input name="table2" type="text" />
</span></td><td><div>
bar
</div></td></tr></table><hr /><span class="submit">
<input name="submit" type="submit" />
</span></fieldset></form>};

    is( "$form", $xhtml );
}
