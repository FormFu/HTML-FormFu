use strict;
use warnings;

use Test::More tests => 49;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t/nested/constraints/constraint_when.yml');

# When triggered depending on callback
my $when_closure = sub {
    my $params = shift;
    return 1 if defined $params->{xyz}{foo} && $params->{xyz}{foo} eq '1';
};

$form->get_field('coo')->get_constraint->when({ callback => $when_closure });

# Just to test we can provide strings as callbacks
# used by "coo2" field
sub when_string_callback { return 1 }

# Valid
{
    $form->process( {
            'xyz.foo' => 1,
            'xyz.bar' => 'bar_value',
            'xyz.moo' => undef,
            'xyz.zoo' => 'zoo_value',
            'xyz.coo' => 4,
            'xyz.coo2' => 5,
        } );

    # if 'moo' does not *exist* in process params
    # it wouldn't be valid

    ok( $form->valid('xyz.foo'), 'foo valid' );
    ok( $form->valid('xyz.bar'), 'bar valid' );
    ok( $form->valid('xyz.moo'), 'moo valid' );
    ok( $form->valid('xyz.zoo'), 'zoo valid' );
    ok( $form->valid('xyz.coo'), 'coo valid' );
    ok( $form->valid('xyz.coo2'), 'coo2 valid' );

    ok( grep { $_ eq 'xyz.foo' } $form->valid );
    ok( grep { $_ eq 'xyz.bar' } $form->valid );
    ok( grep { $_ eq 'xyz.moo' } $form->valid );
    ok( grep { $_ eq 'xyz.zoo' } $form->valid );
    ok( grep { $_ eq 'xyz.coo' } $form->valid );
    ok( grep { $_ eq 'xyz.coo2' } $form->valid );
}
{
    $form->process( {
            'xyz.foo' => 2,
            'xyz.bar' => undef,
            'xyz.moo' => 'moo_value',
            'xyz.zoo' => 'zoo_value',
            'xyz.coo' => 'not_a_number',
        } );

    # if 'bar' does not *exist* in process params
    # it wouldn't be valid

    ok( $form->valid('xyz.foo'), 'foo valid' );
    ok( $form->valid('xyz.bar'), 'bar valid' );
    ok( $form->valid('xyz.moo'), 'moo valid' );
    ok( $form->valid('xyz.zoo'), 'zoo valid' );
    ok( $form->valid('xyz.coo'), 'coo valid' );

    ok( grep { $_ eq 'xyz.foo' } $form->valid );
    ok( grep { $_ eq 'xyz.bar' } $form->valid );
    ok( grep { $_ eq 'xyz.moo' } $form->valid );
    ok( grep { $_ eq 'xyz.zoo' } $form->valid );
    ok( grep { $_ eq 'xyz.coo' } $form->valid );
}
{
    $form->process( {
            'xyz.foo' => 5,
            'xyz.bar' => undef,
            'xyz.moo' => undef,
            'xyz.zoo' => undef,
            'xyz.coo' => undef,
        } );

    # if 'bar' does not *exist* in process params
    # it wouldn't be valid

    ok( $form->valid('xyz.foo'), 'foo valid' );
    ok( $form->valid('xyz.bar'), 'bar valid' );
    ok( $form->valid('xyz.moo'), 'moo valid' );
    ok( $form->valid('xyz.zoo'), 'zoo valid' );
    ok( $form->valid('xyz.coo'), 'coo valid' );

    ok( grep { $_ eq 'xyz.foo' } $form->valid );
    ok( grep { $_ eq 'xyz.bar' } $form->valid );
    ok( grep { $_ eq 'xyz.moo' } $form->valid );
    ok( grep { $_ eq 'xyz.zoo' } $form->valid );
    ok( grep { $_ eq 'xyz.coo' } $form->valid );
}

# Invalid
{
    $form->process( {
            'xyz.foo' => 1,
            'xyz.moo' => undef,
            'xyz.coo' => 'not_a_number',
        } );

    ok( $form->has_errors );

    ok( $form->valid('xyz.foo'),  'foo valid' );
    ok( !$form->valid('xyz.bar'), 'bar not valid' );
    ok( $form->valid('xyz.moo'),  'moo valid' );
    ok( !$form->valid('xyz.zoo'), 'zoo not valid' );
    ok( !$form->valid('xyz.coo'), 'coo not valid' );

    $form->process( {
            'xyz.foo' => 'false value',
            'xyz.bar' => undef,
            'xyz.moo' => undef,
            'xyz.zoo' => 'zoo_value',
            'xyz.coo' => 'not_a_number',
        } );

    # if 'bar' and 'moo' does not *exist* in process params
    # it wouldn't be valid

    ok( $form->has_errors );

    ok( !$form->valid('xyz.foo'), 'foo not valid' );
    ok( $form->valid('xyz.bar'),  'bar valid' );
    ok( $form->valid('xyz.moo'),  'moo valid' );
    ok( $form->valid('xyz.zoo'),  'zoo valid' );
    ok( $form->valid('xyz.coo'),  'coo valid' );

    ok( !grep { $_ eq 'xyz.foo' } $form->valid );
    ok( grep  { $_ eq 'xyz.bar' } $form->valid );
    ok( grep  { $_ eq 'xyz.moo' } $form->valid );
    ok( grep  { $_ eq 'xyz.zoo' } $form->valid );
    ok( grep  { $_ eq 'xyz.coo' } $form->valid );
}
