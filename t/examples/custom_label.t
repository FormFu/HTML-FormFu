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
[% render.start_form %]
[% render.element('type', 'Fieldset').start %]
[% render.field('foo').label_tag %]: [% render.field('foo').field_tag %]
[% render.field('bar').label_tag %]: [% render.field('bar').field_tag %]
[% render.field('baz') %]
[% render.field('submit') %]
[% render.element('type', 'Fieldset').end %]
[% render.end_form %]
</body>
</html>
