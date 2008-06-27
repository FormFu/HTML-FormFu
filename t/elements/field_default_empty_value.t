use strict;
use warnings;

use Test::More tests => 1;
use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element({ name => 'foo' });
$form->element({ name => 'bar' })->default_empty_value(1);

$form->process({ foo => 42 });

is_deeply(
    $form->params,
    {
        foo => 42,
        bar => '',
    }
);
