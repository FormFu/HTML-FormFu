use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t/elements/block_repeatable_inc.yml');

my $fs    = $form->get_element;
my $block = $fs->get_element;

$block->repeat(1);
$block->repeat(1);

# ensure one 1 was added, total

my $elems = $block->get_elements;

ok( scalar @$elems == 1 );

is( $form, <<HTML );
<form action="" method="post">
<fieldset>
<div>
<div>
<input name="foo_1" type="text" />
</div>
<div>
<input name="bar_1" type="text" />
</div>
</div>
<div>
<input name="submit" type="submit" />
</div>
</fieldset>
</form>
HTML
