use strict;
use warnings;

our $count;
BEGIN { $count = 3 }
use Test::More tests => $count;

use HTML::FormFu;
use lib 't/lib';

SKIP: {
    eval "use MyApp::Schema";

    skip 'DBIx::Class needed', $count if $@;

    my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

    $form->element( { name => 'title' } );
    $form->element( { name => 'name' } );
    $form->element( { name => 'age' } );

    my $schema = MyApp::Schema->connect;

    $form->constraints_from_dbic( $schema->resultset('Person') );

    is( @{ $form->get_field('title')->get_constraints }, 1 );
    is( @{ $form->get_field('name')->get_constraints },  1 );
    is( @{ $form->get_field('age')->get_constraints },   2 );

}
