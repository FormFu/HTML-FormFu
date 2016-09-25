use strict;
use warnings;

use Test::More tests => 9;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t/constraints/constraint_when_any_true_value.yml');

# Valid
{
    $form->process( {
            foo => 'a',
            bar => 'b',
        } );

    ok( $form->submitted_and_valid );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
}

# valid
{
    $form->process( {
            foo => '',
            bar => 'b',
        } );

    ok( $form->submitted_and_valid );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
}

# Invalid
{
    $form->process( {
            foo => 'a',
            bar => '',
        } );

    ok( $form->has_errors );

    ok( $form->valid('foo'),  'foo valid' );
    ok( !$form->valid('bar'), 'bar not valid' );
}
