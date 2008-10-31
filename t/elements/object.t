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

# testing templates
# never want to run using string method
delete $ENV{HTML_FORMFU_RENDER_METHOD};

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => ['t/elements/object', 'share/templates/tt/xhtml'] } } );

$form->render_method('tt');
$form->auto_fieldset;

$form->element('Text')->name('foo')->constraint('Required');
$form->element('Text')->name('bar');
$form->element('Hidden')->name('baz');
$form->element('Submit')->name('submit');

my $xhtml = <<EOF;
<form action="" method="post">
<div class="text">
<input name="foo" type="text" /> **
</div>
<div class="text">
<input name="bar" type="text" />
</div>
<input name="baz" type="hidden" />
<div class="submit">
<input name="submit" type="submit" />
</div>
</form>
EOF

is( $form, $xhtml );
