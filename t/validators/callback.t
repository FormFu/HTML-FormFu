use strict;
use warnings;

use Test::More tests => 5;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo')->validator('Callback')->callback(\&cb);
$form->element('Text')->name('bar')->validator('Callback')->callback("main::cb");

sub cb {
    my $value = shift;
    ok(1) if grep { $value eq $_ ? 1 : 0 } qw/ 1 0 a /;
    return 1;
}

# Valid
{
    $form->process( {
            foo => 1,
            bar => [ 0, 'a', 'b' ],
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
}
