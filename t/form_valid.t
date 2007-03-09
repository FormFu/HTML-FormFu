use strict;
use warnings;

use Test::More tests => 10;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo');
$form->element('text')->name('bar');
$form->element('text')->name('string');
$form->element('text')->name('missing');

$form->constraint( 'Number', 'foo', 'bar', 'string' );

$form->process( {
        foo     => 1,
        bar     => [ 2, 3 ],
        string  => 'yada',
        unknown => 4,
    } );

ok( grep  { $_ eq 'foo' } $form->valid );
ok( grep  { $_ eq 'bar' } $form->valid );
ok( !grep { $_ eq 'string' } $form->valid );
ok( !grep { $_ eq 'unknown' } $form->valid );
ok( !grep { $_ eq 'missing' } $form->valid );

ok( $form->valid('foo'),      'foo valid' );
ok( $form->valid('bar'),      'bar valid' );
ok( !$form->valid('string'),  'string not valid' );
ok( !$form->valid('unknown'), 'unknown not valid' );
ok( !$form->valid('missing'), 'missing valid' );

