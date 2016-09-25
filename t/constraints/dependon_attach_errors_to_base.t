use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t/constraints/dependon_attach_errors_to_base.yml');

# Valid
{
    $form->process( {
            foo => 'a',
            bar => 'b',
        } );

    ok( $form->submitted_and_valid );
}

# Invalid
{
    $form->process( {
            foo => '',
            bar => 'b',
        } );

    ok( !$form->submitted_and_valid );

    ok( !$form->has_errors('foo') );
    ok( $form->has_errors('bar') );
}
