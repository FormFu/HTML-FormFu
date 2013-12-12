use strict;
use warnings;

use Test::More tests => 11;

use HTML::FormFu;
use lib 't/lib';
use HTMLFormFu::TestLib;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t-aggregate/repeatable/constraints/required.yml');

$form->get_element( { type => 'Repeatable' } )->repeat(2);

# Valid
{
    $form->process( {
            'rep_1.foo' => 'a',
            'rep_1.bar' => 'b',
            'rep_2.foo' => 'c',
            'rep_2.bar' => 'd',
            count       => 2,
        } );

    ok( $form->submitted_and_valid );

    is_deeply(
        $form->params,
        {   rep_1 => {
                foo => 'a',
                bar => 'b',
            },
            rep_2 => {
                foo => 'c',
                bar => 'd',
            },
            count => 2,
        } );
}

# Missing - Invalid
{
    $form->process( {
            'rep_1.bar' => 'b',
            'rep_2.foo' => 'c',
            count       => 2,
        } );

    ok( !$form->submitted_and_valid );

    ok( $form->has_errors('rep_1.foo') );
    ok( !$form->has_errors('rep_1.bar') );
    ok( !$form->has_errors('rep_2.foo') );
    ok( $form->has_errors('rep_2.bar') );

    like( $form->get_field( { nested_name => 'rep_1.foo' } ), qr/This field is required/ );
    unlike( $form->get_field( { nested_name => 'rep_1.bar' } ), qr/This field is required/ );
    unlike( $form->get_field( { nested_name => 'rep_2.foo' } ), qr/This field is required/ );
    like( $form->get_field( { nested_name => 'rep_2.bar' } ), qr/This field is required/ );
}

