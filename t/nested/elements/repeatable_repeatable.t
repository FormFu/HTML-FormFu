use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t/nested/elements/repeatable_repeatable.yml');

$form->process({
    'count'               => 1,
    'outer.foo_1'         => 'aaa',
    'outer.count_1'       => 1,
    'outer.inner.bar_1_1' => 'bbb',
});

ok( $form->submitted_and_valid );

is_deeply(
    $form->params,
    {
        count => 1,
        outer => {
            foo_1   => 'aaa',
            count_1 => 1,
            inner   => {
                bar_1_1 => 'bbb',
            },
        },
    }
);

my $outer = $form->get_element({ type => 'Repeatable' });

my $inner = $outer->get_element->get_element({ type => 'Repeatable' });

is( $outer->get_field->original_name, 'foo' );
is( $inner->get_field->original_name, 'bar' );
