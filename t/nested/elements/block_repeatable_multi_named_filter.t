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
    'nested_1.foo'         => 'aaa',
    'nested_1.multi.bar'   => 'bbb',
    'nested_1.multi.baz'   => 'ccc',
});

ok( $form->submitted_and_valid );

is_deeply(
    $form->params,
    {
        nested_1 => {
            foo   => 'aaa',
            multi => 'bbb ccc'
        }
    }
);

is( $form->param_value('nested_1.foo'),   'aaa' );
is( $form->param_value('nested_1.multi'), 'bbb ccc' );
