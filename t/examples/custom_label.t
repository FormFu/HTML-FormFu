use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;
use Template;

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
[% form.start_form %]
[% form.get_element('type', 'Fieldset').start %]
[% form.get_field('foo').label_tag %]: [% form.get_field('foo').field_tag %]
[% form.get_field('bar').label_tag %]: [% form.get_field('bar').field_tag %]
[% form.get_field('baz') %]
[% form.get_field('submit') %]
[% form.get_element('type', 'Fieldset').end %]
[% form.end_form %]
</body>
</html>
