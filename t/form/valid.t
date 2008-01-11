use strict;
use warnings;

use Test::More tests => 10;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo');
$form->element('Text')->name('bar');
$form->element('Text')->name('string');
$form->element('Text')->name('missing');

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

