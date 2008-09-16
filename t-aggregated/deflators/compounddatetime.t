use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;
use DateTime;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t-aggregated/deflators/compounddatetime.yml');

my $datetime = DateTime->new(
    day   => '31',
    month => '12',
    year  => '1999',
);

$form->get_field('dob')->default($datetime);

my $html = <<HTML;
<form action="" method="post">
<div class="multi">
<span class="elements">
<input name="dob.day" type="text" value="31" />
<input name="dob.month" type="text" value="12" />
<input name="dob.year" type="text" value="1999" />
</span>
</div>
</form>
HTML

is( "$form", $html );
