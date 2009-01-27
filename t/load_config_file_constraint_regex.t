use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new->load_config_file(
    't/load_config_file_constraint_regex.yml');

{
    $form->process( { foo => "foo bar" } );

    ok( $form->valid('foo') );
}

{
    $form->process( { foo => "\n" } );

    ok( $form->has_errors('foo') );
}
