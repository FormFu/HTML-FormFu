use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t-aggregated/deflators/compoundsplit_field_order.yml');

$form->default_values({
    address => '10 Downing Street',
});

$form->process;

my $html = <<HTML;
<form action="" method="post">
<div class="multi">
<span class="elements">
<input name="address.street" type="text" value="Downing Street" />
<input name="address.number" type="text" value="10" />
</span>
</div>
</form>
HTML

is( "$form", $html );
