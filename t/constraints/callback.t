use strict;
use warnings;

use Test::More tests => 5;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo');
$form->element('Text')->name('bar');

sub cb {
    my $value = shift;
    ok(1) if grep { $value eq $_ ? 1 : 0 } qw/ 1 0 a /;
    return 1;
}

$form->constraint( {
        type     => 'Callback',
        callback => \&cb,
    } );

# Valid
{
    $form->process( {
            foo => 1,
            bar => [ 0, 'a' ],
        } );

    ok( $form->valid('foo'), 'foo valid' );
    ok( $form->valid('bar'), 'bar valid' );
}
