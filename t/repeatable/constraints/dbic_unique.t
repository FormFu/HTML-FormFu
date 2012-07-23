use strict;
use warnings;

use Test::More tests => 6;

use HTML::FormFu;
use lib 't/lib';
use HTMLFormFu::TestLib;

my $form = HTML::FormFu->new;

$form->load_config_file('t/repeatable/constraints/dbic_unique.yml');

$form->get_element( { type => 'Repeatable' } )->repeat(2);

# Valid
{
    $form->process( {
            'foo_1' => 'a',
            'bar_1' => 'b',
            'foo_2' => 'c',
            'bar_2' => 'd',
            count       => 2,
        } );

    ok( $form->submitted_and_valid );

    is_deeply(
        $form->params, {
            foo_1 => 'a',
            bar_1 => 'b',
            foo_2 => 'c',
            bar_2 => 'd',
            count => 2,
        } );
    is $form->get_all_element('bar_1')->get_constraints()->[0]->id_field, 'foo_1';
}

# also using a Required constraint to ensure
# another constraint also works.

# Missing - Invalid
{
    $form->process( {
            'foo_1' => 'a',
            'bar_2' => 'b',
            count       => 2,
        } );

    ok( !$form->submitted_and_valid );
    ok( $form->has_errors('foo_2') );
    ok( !$form->has_errors('foo_1') );
}
