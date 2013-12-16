use strict;
use warnings;

use Test::More tests => 7;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t-aggregate/constraints/minmaxfields_with_filter_split.yml');

# Valid
{
    $form->process( {
            foo => '',
            bar => '',
            baz => '',
        } );

    ok( !$form->has_errors );

    $form->process( {
            foo => '1',
            bar => '',
            baz => '',
        } );

    ok( !$form->has_errors );

    $form->process( {
            foo => '1,2',
            bar => '',
            baz => '',
        } );

    ok( !$form->has_errors );
}

# Invalid
{
    $form->process( {
            foo => 1,
            bar => '',
            baz => 2,
        } );

    ok( $form->has_errors );

    ok( !$form->valid('foo') );
    ok( $form->valid('bar') );
    ok( $form->valid('baz') );
}
