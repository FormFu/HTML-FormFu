use strict;
use warnings;

use Test::More tests => 7;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t-aggregated/elements/block_repeatable.yml');

my $fs         = $form->get_element;
my $repeatable = $fs->get_element;

{
    my $return = $repeatable->repeat(2);

    ok( scalar @$return == 2 );
    isa_ok( $return->[0], 'HTML::FormFu::Element::Block' );
    isa_ok( $return->[1], 'HTML::FormFu::Element::Block' );
}

{
    my $elems = $repeatable->get_elements;

    ok( scalar @$elems == 2 );
    isa_ok( $elems->[0], 'HTML::FormFu::Element::Block' );
    isa_ok( $elems->[1], 'HTML::FormFu::Element::Block' );
}

is( $form, <<HTML );
<form action="" method="post">
<fieldset>
<div>
<div class="text">
<input name="foo_1" type="text" />
</div>
<div class="text">
<input name="bar_1" type="text" />
</div>
</div>
<div>
<div class="text">
<input name="foo_2" type="text" />
</div>
<div class="text">
<input name="bar_2" type="text" />
</div>
</div>
<div class="submit">
<input name="submit" type="submit" />
</div>
</fieldset>
</form>
HTML
