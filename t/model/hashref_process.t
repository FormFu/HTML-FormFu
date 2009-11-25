use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->populate(
    {
        elements => [
            { type => 'Hidden', name => 'count' },
            {
                type         => 'Repeatable',
                nested_name  => 'rep',
                counter_name => 'count',
                elements     => [
                    { type => 'Text', name => 'title' },
                    { type => 'Text', name => 'title2' }
                ]
            }
        ]
    }
);

$form->get_element( { nested_name => 'rep' } )->repeat(2);

$form->process(
    { 'rep_1.title' => 'foo', 'rep_1.title2' => 'bar', 'rep_2.title' => 'foo' }
);

is_deeply(
    $form->model('HashRef')->create,
    {
        count => undef,
        rep   => [
            { title => 'foo', title2 => 'bar' },
            { title => 'foo', title2 => undef }
        ]
    }
);
