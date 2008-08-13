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
    { tt_args => { INCLUDE_PATH => ['t/form/object', 'share/templates/tt/xhtml'] } } );

$form->render_method('tt');
$form->auto_fieldset;

$form->element('Text')->name('foo')->label('Foo');
$form->element('Text')->name('bar')->label('Bar');
$form->element('Hidden')->name('baz');
$form->element('Submit')->name('submit');

my $xhtml = <<EOF;
foo
bar
baz
submit
EOF

is( $form, $xhtml );
