use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

#
# The HTML below should never be changed
# If necessary, the form config should be changed to show
# how to achieve legacy HTML generation
#

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t/bugs/pre_1_00_compat.yml');

is( "$form", <<HTML );
<form action="" id="formfu" method="post">
<fieldset>
<div class="text comment label">
<label for="formfu_foo">Foo</label>
<input name="foo" type="text" id="formfu_foo" />
<span class="comment">
The Foo
</span>
</div>
</fieldset>
</form>
HTML

$form->process( { foo => '', } );

is( "$form", <<HTML );
<form action="" id="formfu" method="post">
<fieldset>
<div class="text comment label error error_constraint_required">
<span class="error_message error_constraint_required">This field is required</span>
<label for="formfu_foo">Foo</label>
<input name="foo" type="text" value="" id="formfu_foo" />
<span class="comment">
The Foo
</span>
</div>
</fieldset>
</form>
HTML
