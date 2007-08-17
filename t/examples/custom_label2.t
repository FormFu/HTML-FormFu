use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;
use Template;

my $form = HTML::FormFu->new;
my $fs   = $form->element('Fieldset')->legend('Foo');

$fs->element('Text')->name('foo')->label('Foo');
$fs->element('Text')->name('bar')->label('Bar');
$fs->element('Hidden')->name('baz');
$fs->element('Submit')->name('submit');

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
<body>[% render = form.render %]
[% render.start_form %][% FOREACH fieldset = render.elements %]
[% fieldset.start %][% FOREACH field = fieldset.fields %]
[% IF field.label.defined %][% field.label_tag %]: [% field.field_tag %][% ELSE %][% field %][% END %][% END %]
[% fieldset.end %][% END %]
[% render.end_form %]
</body>
</html>
