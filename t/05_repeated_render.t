use strict;
use warnings;
use Test::More tests => 2;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->load_config_file('t/04basic.yml');

# check output is still exactly the same after rendering again

{
    my $html = "$form";
    
    is( $html, "$form" );
}

# and after submitted form

{
    $form->process({
        age => 'abc',
    });
    
    my $html = "$form";
    
    is( $html, "$form" );
}
