use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

# add config-callback to replicate Catalyst-Controller-HTML-FormFu
$form->config_callback({
    plain_value => sub {
        return if !defined $_;
        s{__uri_for()\((.+?)\)__}
         {$1}g;
    },
});

$form->load_config_file('t/filters/regex.yml');

{
    $form->process({
        foo => '   4.5 ',
    });
    
    ok( $form->submitted_and_valid);

    is( $form->param_value('foo'), '4.5' );
}

{
    # clone form

    my $form = $form->clone;

    $form->process({
        foo => " abc\t",
    });

    ok( $form->submitted_and_valid );

    is( $form->param_value('foo'), 'abc' );
}
