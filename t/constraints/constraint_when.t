use strict;
use warnings;

use Test::More tests => 49;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo')->constraint('Integer');
$form->element('Text')->name('bar')->constraint('Required')
    ->when( { field => 'foo', value => 1 } );
$form->element('Text')->name('moo')->constraint('Required')
    ->when( { field => 'foo', values => [ 2, 3, 4 ] } );
$form->element('Text')->name('zoo')->constraint('Required')
    ->when( { field => 'foo', value => 5, not => 1 } );

# When triggered depending on callback
my $when_closure = sub {
    my $params = shift;
    return 1 if defined $params->{foo} && $params->{foo} eq '1';
};
$form->element('Text')->name('coo')->constraint('Number')
    ->when( { callback => $when_closure } );
# Just to test we can provide strings as callbacks
$form->element('Text')->name('coo2')->constraint('Integer')
    ->when( { callback => "main::when_string_callback" } );
sub when_string_callback { return 1 }

# Valid
{
    $form->process( {
            foo => 1,
            bar => 'bar_value',
            moo => undef,
            zoo => 'zoo_value',
            coo => 4,
            coo2 => 5,
        } );

    # if 'moo' does not *exist* in process params
    # it wouldn't be valid

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
    ok( $form->valid('moo'), 'moo valid' );
    ok( $form->valid('zoo'), 'zoo valid' );
    ok( $form->valid('coo'), 'coo valid' );
    ok( $form->valid('coo2'), 'coo2 valid' );

    ok( grep { $_ eq 'foo' } $form->valid );
    ok( grep { $_ eq 'bar' } $form->valid );
    ok( grep { $_ eq 'moo' } $form->valid );
    ok( grep { $_ eq 'zoo' } $form->valid );
    ok( grep { $_ eq 'coo' } $form->valid );
    ok( grep { $_ eq 'coo2' } $form->valid );

    $form->process( {
            foo => 2,
            bar => undef,
            moo => 'moo_value',
            zoo => 'zoo_value',
            coo => 'not_a_number',
        } );

    # if 'bar' does not *exist* in process params
    # it wouldn't be valid

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
    ok( $form->valid('moo'), 'moo valid' );
    ok( $form->valid('zoo'), 'zoo valid' );
    ok( $form->valid('coo'), 'coo valid' );

    ok( grep { $_ eq 'foo' } $form->valid );
    ok( grep { $_ eq 'bar' } $form->valid );
    ok( grep { $_ eq 'moo' } $form->valid );
    ok( grep { $_ eq 'zoo' } $form->valid );
    ok( grep { $_ eq 'coo' } $form->valid );

    $form->process( {
            foo => 5,
            bar => undef,
            moo => undef,
            zoo => undef,
            coo => undef,
        } );

    # if 'bar' does not *exist* in process params
    # it wouldn't be valid

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
    ok( $form->valid('moo'), 'moo valid' );
    ok( $form->valid('zoo'), 'zoo valid' );
    ok( $form->valid('coo'), 'coo valid' );

    ok( grep { $_ eq 'foo' } $form->valid );
    ok( grep { $_ eq 'bar' } $form->valid );
    ok( grep { $_ eq 'moo' } $form->valid );
    ok( grep { $_ eq 'zoo' } $form->valid );
    ok( grep { $_ eq 'coo' } $form->valid );
}

# Invalid
{
    $form->process( {
            foo => 1,
            moo => undef,
            coo => 'not_a_number',
        } );

    ok( $form->has_errors );

    ok( $form->valid('foo'),  'foo valid' );
    ok( !$form->valid('bar'), 'bar not valid' );
    ok( $form->valid('moo'),  'moo valid' );
    ok( !$form->valid('zoo'), 'zoo not valid' );
    ok( !$form->valid('coo'), 'coo not valid' );

    $form->process( {
            foo => 'false value',
            bar => undef,
            moo => undef,
            zoo => 'zoo_value',
            coo => 'not_a_number',
        } );

    # if 'bar' and 'moo' does not *exist* in process params
    # it wouldn't be valid

    ok( $form->has_errors );

    ok( !$form->valid('foo'), 'foo not valid' );
    ok( $form->valid('bar'),  'bar valid' );
    ok( $form->valid('moo'),  'moo valid' );
    ok( $form->valid('zoo'),  'zoo valid' );
    ok( $form->valid('coo'),  'coo valid' );

    ok( !grep { $_ eq 'foo' } $form->valid );
    ok( grep  { $_ eq 'bar' } $form->valid );
    ok( grep  { $_ eq 'moo' } $form->valid );
    ok( grep  { $_ eq 'zoo' } $form->valid );
    ok( grep  { $_ eq 'coo' } $form->valid );
}
