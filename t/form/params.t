use strict;
use warnings;

use Test::More tests => 6;

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

my $params = $form->params;

ok( grep  { $_ eq 'foo' } keys %$params );
ok( grep  { $_ eq 'bar' } keys %$params );
ok( !grep { $_ eq 'string' } keys %$params );
ok( !grep { $_ eq 'unknown' } keys %$params );

is( $params->{foo}, 1, 'foo params' );

is_deeply( $params->{bar}, [ 2, 3 ], 'bar params' );

