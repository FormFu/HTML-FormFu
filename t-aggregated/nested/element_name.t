use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t-aggregated/nested/element_name.yml');

is( $form->get_field('bar')->nested_name, 'foo.bar' );

my $baz_fs = $form->get_element( { type => 'Fieldset' } )
    ->get_element( { type => 'Block' } );

is( $baz_fs->get_field('0')->nested_name, 'foo.baz.0' );

is( "$form", <<EO_RENDER );
<form action="" method="post">
<fieldset>
<div class="text">
<input name="foo.bar" type="text" id="foo.bar" />
</div>
<div>
<div class="text">
<input name="foo.baz.0" type="text" id="foo.baz.0" />
</div>
</div>
</fieldset>
</form>
EO_RENDER
