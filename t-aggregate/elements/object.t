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

# testing templates
# never want to run using string method
delete $ENV{HTML_FORMFU_RENDER_METHOD};

use HTML::FormFu;

my $form = HTML::FormFu->new( {
        tt_args => {
            INCLUDE_PATH => [ 't-aggregate/elements/object', 'share/templates/tt/xhtml' ]
        } } );

$form->render_method('tt');
$form->auto_fieldset;

$form->element('Text')->name('foo')->layout_field_filename('field_layout_field_custom')->constraint('Required');
$form->element('Text')->name('bar');
$form->element('Hidden')->name('baz');
$form->element('Submit')->name('submit');

my $xhtml = <<EOF;
<form action="" method="post">
<div>
<input name="foo" type="text" /> **
</div>
<div>
<input name="bar" type="text" />
</div>
<input name="baz" type="hidden" />
<div>
<input name="submit" type="submit" />
</div>
</form>
EOF

is( $form, $xhtml );
