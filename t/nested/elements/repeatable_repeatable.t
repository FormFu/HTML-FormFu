use strict;
use warnings;

use Test::More tests => 6;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t/nested/elements/repeatable_repeatable.yml');

$form->process({
    'count'               => 2,
    'outer_1.foo'         => 'a',
    'outer_1.count'       => 3,
    'outer_1.inner_1.bar' => 'b',
    'outer_1.inner_2.bar' => 'c',
    'outer_1.inner_3.bar' => 'd',
    'outer_2.foo'         => 'e',
    'outer_2.count'       => 4,
    'outer_2.inner_1.bar' => 'f',
    'outer_2.inner_2.bar' => 'g',
    'outer_2.inner_3.bar' => 'h',
    'outer_2.inner_4.bar' => 'i',
});

ok( $form->submitted_and_valid );

is_deeply(
    $form->params,
    {
        count => 2,
        outer_1 => {
            foo   => 'a',
            count => 3,
            inner_1 => {
                bar => 'b',
            },
            inner_2 => {
                bar => 'c',
            },
            inner_3 => {
                bar => 'd',
            },
        },
        outer_2 => {
            foo   => 'e',
            count => 4,
            inner_1 => {
                bar => 'f',
            },
            inner_2 => {
                bar => 'g',
            },
            inner_3 => {
                bar => 'h',
            },
            inner_4 => {
                bar => 'i',
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
