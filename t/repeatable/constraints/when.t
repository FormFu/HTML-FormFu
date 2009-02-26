use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;
use lib 't/lib';
use HTMLFormFu::TestLib;

my $form = HTML::FormFu->new;

$form->load_config_file('t/repeatable/constraints/when.yml');

$form->get_element( { type => 'Repeatable' } )->repeat(1);

# Valid
{
    $form->process( {
            'rep.foo_1' => 'a',
            'rep.bar_1' => 'b',
            count       => 1,
        } );

    ok( $form->submitted_and_valid );
}

# Missing - Invalid
{
    $form->process( {
            'rep.foo_1' => 'a',
            'rep.bar_1' => '',
            count       => 1,
        } );

    ok( $form->has_errors );

    ok( $form->valid('rep.foo_1') );
    ok( !$form->valid('rep.bar_1') );
}

