use strict;
use warnings;
use lib 't/lib';

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    {   localize_class => 'HTMLFormFu::I18N',
        tt_args        => { INCLUDE_PATH => 'share/templates/tt/xhtml' },
    } );

$form->load_config_file('t/elements/text_datalist_options.yml');

my $expected_form_xhtml = <<EOF;
<form action="" id="form" method="post">
<div>
<datalist id="form_foo_datalist">
<option value="one">One</option>
<option value="two">Two</option>
<option value="three">My Label</option>
<option value="&gt;four">Four</option>
</datalist>
<input name="foo" type="text" id="form_foo" list="form_foo_datalist" />
</div>
</form>
EOF

is( "$form", $expected_form_xhtml );
