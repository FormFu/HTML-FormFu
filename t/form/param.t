use strict;
use warnings;

use Test::More tests => 9;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo');
$form->element('text')->name('bar');
$form->element('text')->name('string');

$form->constraint( 'Number', 'foo', 'bar', 'string' );

$form->process( {
        foo     => 1,
        bar     => [ 2, 3 ],
        string  => 'yada',
        unknown => 4,
    } );

ok( grep  { $_ eq 'foo' } $form->param );
ok( grep  { $_ eq 'bar' } $form->param );
ok( !grep { $_ eq 'string' } $form->param );
ok( !grep { $_ eq 'unknown' } $form->param );

is( $form->param('foo'), 1, 'foo param' );

my $bar = $form->param('bar');
is( $bar, 2, 'bar param scalar context' );
my @bar = $form->param('bar');
is_deeply( \@bar, [ 2, 3 ], 'bar param list context' );

ok( !$form->param('string'),  'string param not returned' );
ok( !$form->param('unknown'), 'unknown param not returned' );

