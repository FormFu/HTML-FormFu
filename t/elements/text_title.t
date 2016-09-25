use strict;
use warnings;
use lib 't/lib';

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new( {
    localize_class => 'HTMLFormFu::I18N',
    tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' },
} );

$form->element('Text')->name('foo')->title('The Foo');
$form->element('Text')->name('bar')->title_loc('bar_title');

my $expected_form_xhtml = <<EOF;
<form action="" method="post">
<div>
<input name="foo" type="text" title="The Foo" />
</div>
<div>
<input name="bar" type="text" title="The Bar Title" />
</div>
</form>
EOF

is( "$form", $expected_form_xhtml );
