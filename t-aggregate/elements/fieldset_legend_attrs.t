use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

my $outer = $form->load_config_file('t-aggregate/elements/fieldset_legend_attrs.yml');

my $form_xhtml = <<EOF;
<form action="" method="post">
<fieldset>
<legend class="my_legend">The Legend!</legend>
The Content!
</fieldset>
</form>
EOF

is( "$form", $form_xhtml );

