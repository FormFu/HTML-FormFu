use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t/nested/elements/block_repeatable_multi_named_filter.yml');

my $fieldset   = $form->get_element;
my $repeatable = $fieldset->get_element;
my $multi      = $repeatable->get_element;

$form->process({
    'counter'              => 1,
    'nested.foo_1'         => 'aaa',
    'nested.multi_1.bar_1' => 'bbb',
    'nested.multi_1.baz_1' => 'ccc',
});

ok( $form->submitted_and_valid );

is_deeply(
    $form->params,
    {
        nested => {
            foo_1 => 'aaa',
            multi_1 => 'bbb ccc'
        }
    }
);

is( $form->param_value('nested.foo_1'), 'aaa' );
is( $form->param_value('nested.multi_1'), 'bbb ccc' );
