use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t/elements/select_attributes_escaped.yml');
$form->process;

my $field = $form->get_field('foo');

my $html = qq{<div class="select">
<select name="foo">
<option value="1" myattr="escape&#38;attr">First</option>
<option value="2" myattr="noescape&amp;">Second</option>
</select>
</div>};

is( "$field", $html );
