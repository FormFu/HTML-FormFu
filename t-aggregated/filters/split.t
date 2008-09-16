use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t-aggregated/filters/split.yml');

$form->process({
    foo => 'FOO',
    bar => '1-2-3',
});

is_deeply(
    $form->param_array('foo'),
    ['F', 'O', 'O']
);

is( $form->param_value('foo'), 'F' );

is_deeply(
    $form->param_array('bar'),
    [1, '2-3']
);

is( $form->param_value('bar'), 1 );
