use strict;
use warnings;

our $count;
BEGIN { $count = 14 }
use Test::More tests => $count;

use HTML::FormFu;
use lib 't/lib';

SKIP: {
    eval "use MyApp::Schema";

    skip 'DBIx::Class needed', $count if $@;

    my $form = HTML::FormFu->new;

    $form->element( { name => 'title' } );
    $form->element( { name => 'name' } );
    $form->element( { name => 'age' } );
    $form->element( { name => 'dongle' } );

    $form->constraints_from_dbic( 'MyApp::Schema::Person',
        { dongle => 'MyApp::Schema::Dongle', } );

    is( @{ $form->get_field('title')->get_constraints },  1 );
    is( @{ $form->get_field('name')->get_constraints },   1 );
    is( @{ $form->get_field('age')->get_constraints },    2 );
    is( @{ $form->get_field('dongle')->get_constraints }, 1 );
    is( @{ $form->get_constraints },                      5 );

    # title - set
    {
        $form->process( { title => 'Mr' } );
        ok( $form->submitted_and_valid );
    }
    {
        $form->process( { title => 'Mz' } );
        ok( $form->has_errors );
    }

    # name - string length
    {
        $form->process( { name => 'carl' } );
        ok( $form->submitted_and_valid );
    }
    {
        $form->process( { name => 'a' x 300 } );
        ok( $form->has_errors );
    }

    # age - int
    {
        $form->process( { age => 1 } );
        ok( $form->submitted_and_valid );
    }
    {
        $form->process( { age => 'a' } );
        ok( $form->has_errors );
    }

    # age - unsigned
    {
        $form->process( { age => -1 } );
        ok( $form->has_errors );
    }

    # dongle - string length
    {
        $form->process( { dongle => 'carl' } );
        ok( $form->submitted_and_valid );
    }
    {
        $form->process( { dongle => 'a' x 11 } );
        ok( $form->has_errors );
    }
}
