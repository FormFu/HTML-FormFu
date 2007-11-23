use strict;
use warnings;

use Test::More tests => 38;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo')->constraint('Integer');
$form->element('Text')->name('bar')->constraint('Required')->when( { field => 'foo', value  => 1 } );
$form->element('Text')->name('moo')->constraint('Required')->when( { field => 'foo', values => [ 2, 3, 4 ] } );
$form->element('Text')->name('zoo')->constraint('Required')->when( { field => 'foo', value  => 5, not => 1 } );


# Valid
{
    $form->process( {
            foo => 1,
            bar => 'bar_value',
            moo => undef,
            zoo => 'zoo_value',
        } );
    # if 'moo' does not *exist* in process params
    # it wouldn't be valid

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
    ok( $form->valid('moo'), 'moo valid' );
    ok( $form->valid('zoo'), 'zoo valid' );

    ok( grep { $_ eq 'foo' } $form->valid );
    ok( grep { $_ eq 'bar' } $form->valid );
    ok( grep { $_ eq 'moo' } $form->valid );
    ok( grep { $_ eq 'zoo' } $form->valid );


    $form->process( {
            foo => 2,
            bar => undef,
            moo => 'moo_value',
            zoo => 'zoo_value',
        } );
    # if 'bar' does not *exist* in process params
    # it wouldn't be valid

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
    ok( $form->valid('moo'), 'moo valid' );
    ok( $form->valid('zoo'), 'zoo valid' );

    ok( grep { $_ eq 'foo' } $form->valid );
    ok( grep { $_ eq 'bar' } $form->valid );
    ok( grep { $_ eq 'moo' } $form->valid );
    ok( grep { $_ eq 'zoo' } $form->valid );


    $form->process( {
            foo => 5,
            bar => undef,
            moo => undef,
            zoo => undef,
        } );
    # if 'bar' does not *exist* in process params
    # it wouldn't be valid

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
    ok( $form->valid('moo'), 'moo valid' );
    ok( $form->valid('zoo'), 'zoo valid' );

    ok( grep { $_ eq 'foo' } $form->valid );
    ok( grep { $_ eq 'bar' } $form->valid );
    ok( grep { $_ eq 'moo' } $form->valid );
    ok( grep { $_ eq 'zoo' } $form->valid );
}


# Invalid
{
    $form->process( {
            foo => 1,
            moo => undef,
        } );

    ok( $form->has_errors );

    ok( $form->valid('foo'),  'foo valid' );
    ok( !$form->valid('bar'), 'bar not valid' );
    ok( $form->valid('moo'),  'moo valid' );
    ok( !$form->valid('zoo'), 'zoo not valid' );


    $form->process( {
            foo => 'false value',
            bar => undef,
            moo => undef,
            zoo => 'zoo_value',
        } );
    # if 'bar' and 'moo' does not *exist* in process params
    # it wouldn't be valid

    ok( $form->has_errors );

    ok( !$form->valid('foo'), 'foo not valid' );
    ok( $form->valid('bar'), 'bar valid' );
    ok( $form->valid('moo'), 'moo valid' );
    ok( $form->valid('zoo'), 'zoo valid' );

    ok( !grep { $_ eq 'foo' } $form->valid );
    ok( grep { $_ eq 'bar' } $form->valid );
    ok( grep { $_ eq 'moo' } $form->valid );
    ok( grep { $_ eq 'zoo' } $form->valid );
}
