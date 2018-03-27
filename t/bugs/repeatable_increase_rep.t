use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t/bugs/repeatable_increase_rep.yml');

my $repeatable = $form->get_all_element( { type => 'Repeatable' } );

{
    # form is submitted with a single value

    $form->process( { foo => 'a' } );

    my $html = qq{<div>
<div>
<input name="foo" type="text" value="a" />
</div>
</div>};

    is( $repeatable, $html );
}

{
    # manually increase repetitions.
    # want to ensure every rep doesn't get the same value

    $repeatable->repeat(2);
    $form->process;

    my $html = qq{<div>
<div>
<input name="foo" type="text" value="a" />
</div>
</div>
<div>
<div>
<input name="foo" type="text" />
</div>
</div>};

    is( $repeatable, $html );
}
