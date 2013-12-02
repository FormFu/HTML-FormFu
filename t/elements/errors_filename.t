use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

# ensure our form is using 'string'
delete $ENV{HTML_FORMFU_RENDER_METHOD};

# tt only needs to find our custom template
my $form = HTML::FormFu->new;

$form->load_config_file('t/elements/errors_filename.yml');

$form->process({
    foo => 'a',
});

is( "$form", <<HTML );
<form action="" method="post">
<div class="text error error_constraint_integer">
<ul>
<li for="foo">This field must be an integer</li>
</ul>
<input name="foo" type="text" value="a" />
</div>
</form>
HTML

