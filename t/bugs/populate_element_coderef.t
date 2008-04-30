use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

my $callback = sub {
    my $value = shift;
    
    Test::More::ok(1) if $value eq 'a';
    
    return 1;
};

my $form = HTML::FormFu->new;

$form->populate({
    elements => [
        {
            name => 'foo',
            constraint => {
                type => 'Callback',
                callback => $callback,
            },
        },
    ],
});

# Valid
{
    $form->process( {
            foo => 'a',
        } );

    ok( $form->valid('foo'), 'foo valid' );
}
