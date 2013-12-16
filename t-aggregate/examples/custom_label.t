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

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->auto_fieldset( { legend => 'Foo' } );

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
<div class="submit">
<input name="submit" type="submit" />
</div>
</fieldset>
</form>
</body>
</html>
EOF

is( $output, $xhtml );

__DATA__
<html>
<body>
[% form.start %]
[% form.get_element('type', 'Fieldset').start %]
[% form.get_field('foo').render_label %]: [% form.get_field('foo').render_field %]
[% form.get_field('bar').render_label %]: [% form.get_field('bar').render_field %]
[% form.get_field('baz') %]
[% form.get_field('submit') %]
[% form.get_element('type', 'Fieldset').end %]
[% form.end %]
</body>
</html>
