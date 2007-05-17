use strict;
use warnings;

our $count;
BEGIN { $count = 10 }
use Test::More tests => $count;

use HTML::FormFu;
use lib 't/lib';

SKIP: {
    eval "use MyApp::Schema";
    warn $@ if $@;
    skip 'DBIx::Class needed', $count if $@;
    
    my $form = HTML::FormFu->new;
    
    $form->element({ name => 'id' });
    $form->element({ name => 'title' });
    $form->element({ name => 'name' });
    
    $form->constraints_from_dbic([ 'MyApp::Schema' => 'Person' ]);
    
    is ( @{ $form->get_field('id')->get_constraints },    2 );
    is ( @{ $form->get_field('title')->get_constraints }, 1 );
    is ( @{ $form->get_field('name')->get_constraints },  1 );
    
    # int
    {
        $form->process({ id => 1 });
        ok( $form->submitted_and_valid );
    }
    {
        $form->process({ id => 'a' });
        ok( $form->has_errors );
    }
    # unsigned
    {
        $form->process({ id => -1 });
        ok( $form->has_errors );
    }
    
    
    # set
    {
        $form->process({ title => 'Mr' });
        ok( $form->submitted_and_valid );
    }
    {
        $form->process({ title => 'Mz' });
        ok( $form->has_errors );
    }
    
    
    # string length
    {
        $form->process({ name => 'carl' });
        ok( $form->submitted_and_valid );
    }
    {
        $form->process({ name => 'a' x 300 });
        ok( $form->has_errors );
    }
}
