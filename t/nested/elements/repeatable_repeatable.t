use strict;
use warnings;

use Test::More tests => 6;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t/nested/elements/repeatable_repeatable.yml');

$form->process({
    'count'               => 1,
    'outer_1.foo'         => 'aaa',
    'outer_1.count'       => 1,
    'outer_1.inner_1.bar' => 'bbb',
});

ok( $form->submitted_and_valid );

is_deeply(
    $form->params,
    {
        count => 1,
        outer_1 => {
            foo   => 'aaa',
            count => 1,
            inner_1   => {
                bar => 'bbb',
            },
        },
    }
);

my $outer = $form->get_element({ type => 'Repeatable' });

my $inner = $outer->get_element->get_element({ type => 'Repeatable' });

is( $outer->original_nested_name, 'outer' );
is( $inner->original_nested_name, 'inner' );
is( $outer->get_field->original_name, 'foo' );
is( $inner->get_field->original_name, 'bar' );
