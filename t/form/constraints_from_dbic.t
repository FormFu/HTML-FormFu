use strict;
use warnings;

our $count;
BEGIN { $count = 17 }
use Test::More tests => $count;

use HTML::FormFu;
use lib 't/lib';

SKIP: {
    eval "use MyApp::Schema";

    skip 'DBIx::Class needed', $count if $@;

    my $form = HTML::FormFu->new(
        { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

    $form->load_config_file('t/form/constraints_from_dbic.yml');

    is( @{ $form->get_field( { nested_name => 'title' } )->get_constraints },
        1 );
    is( @{ $form->get_field( { nested_name => 'name' } )->get_constraints },
        1 );
    is( @{ $form->get_field( { nested_name => 'age' } )->get_constraints }, 2 );
    is( @{  $form->get_field( { nested_name => 'dongle' } )->get_constraints
        },
        1
    );

    is( @{  $form->get_field( { nested_name => 'parent.title' } )
                ->get_constraints
        },
        1
    );
    is( @{  $form->get_field( { nested_name => 'parent.name' } )
                ->get_constraints
        },
        1
    );
    is( @{  $form->get_field( { nested_name => 'parent.age' } )
                ->get_constraints
        },
        2
    );

    is( @{ $form->get_constraints },
        9, "parent Block fields didn't get duplicate constraints" );

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
