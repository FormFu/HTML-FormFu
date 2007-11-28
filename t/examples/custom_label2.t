use strict;
use warnings;
use Test::More;

eval { require Template; };

if ($@) {
    plan skip_all => 'Template.pm required';
    exit;
}
else {
    plan tests => 1;
}

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->auto_fieldset({ legend => 'Foo' });

$form->element('Text')->name('foo')->label('Foo');
$form->element('Text')->name('bar')->label('Bar');
$form->element('Hidden')->name('baz');
$form->element('Submit')->name('submit');

my $template = Template->new;
my $output;

$template->process( \*DATA, { form => $form }, \$output )
    or die $template->error;

my $xhtml = <<EOF;
<html>
<body>
<form action="" method="post">
<fieldset>
<legend>Foo</legend>
<label>Foo</label>: <input name="foo" type="text" />
<label>Bar</label>: <input name="bar" type="text" />
<input name="baz" type="hidden" />
<span class="submit">
<input name="submit" type="submit" />
</span>
</fieldset>
</form>
</body>
</html>
EOF

is( $output, $xhtml );

__DATA__
<html>
<body>
[% form.start %][% FOREACH fieldset = form.get_elements %]
[% fieldset.start %][% FOREACH field = fieldset.get_fields %]
[% IF field.label.defined %][% field.render_label %]: [% field.render_field %][% ELSE %][% field %][% END %][% END %]
[% fieldset.end %][% END %]
[% form.end %]
</body>
</html>
