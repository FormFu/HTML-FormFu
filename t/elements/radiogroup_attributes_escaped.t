use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t/elements/radiogroup_attributes_escaped.yml');
$form->process;

my $field = $form->get_field('foo');

my $html = qq{<fieldset>
<span>
<span myattr="escape&#38;container">
<input name="foo" type="radio" value="1" myattr="escape&#38;attr" />
<label myattr="escape&#38;label">First</label>
</span>
<span>
<input name="foo" type="radio" value="2" myattr="noescape&amp;" />
<label>Second</label>
</span>
</span>
</fieldset>};

is( "$field", $html );
