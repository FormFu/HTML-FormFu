use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t/deflators/compoundsplit_after_submit.yml');

$form->process({
    'address.number' => '10',
    'address.street' => 'Downing Street',
});

# check Filter::CompoundJoin worked ok

is( $form->param_value('address'), '10 Downing Street' );

my $html = <<HTML;
<form action="" method="post">
<div class="multi">
<span class="elements">
<input name="address.number" type="text" value="10" />
<input name="address.street" type="text" value="Downing Street" />
</span>
</div>
</form>
HTML

is ( "$form", $html );
