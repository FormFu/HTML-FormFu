use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t-aggregated/filters/regex.yml');

{
    $form->process({
        foo => '   4.5 ',
    });
    
    ok( $form->submitted_and_valid);

    is( $form->param_value('foo'), '4.5' );
}

# check cloning form works
$form = $form->clone;

{
    $form->process({
        foo => " abc\t",
    });

    ok( $form->submitted_and_valid );

    is( $form->param_value('foo'), 'abc' );
}
