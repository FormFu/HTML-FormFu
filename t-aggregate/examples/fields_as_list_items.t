use strict;
use warnings;

use Test::More;

eval { require Template; };

if ($@) {
    plan skip_all => 'Template.pm required';
    die $@;
}
else {
    plan tests => 1;
}

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo')->label('Foo');
$form->element('Textarea')->name('bar')->label('Bar');

my $template = Template->new;
my $output;

$template->process( \*DATA, { form => $form }, \$output )
    or die $template->error;

my $xhtml = <<EOF;
<html>
<body>
<form action="" method="post">
<ul>
    <li><label>Foo</label> : <input name="foo" type="text" /></li>
    <li><label>Bar</label> : <textarea name="bar" cols="40" rows="20"></textarea></li>
</ul>
</form>
</body>
</html>
EOF

is( $output, $xhtml );

__DATA__
<html>
<body>
[% form.start %]
<ul>[% FOREACH field = form.get_fields %]
    <li>[% field.render_label %] : [% field.render_field %]</li>[% END %]
</ul>
[% form.end %]
</body>
</html>
