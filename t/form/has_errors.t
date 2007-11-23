use strict;
use warnings;

use Test::More tests => 6;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->element('Text')->name('foo');
$form->element('Text')->name('bar');
$form->element('Text')->name('string');

$form->constraint( 'Number', 'foo', 'bar', 'string' );

$form->process( {
        foo    => 1,
        bar    => [ 2, 3 ],
        string => 'yada',
    } );

ok( !grep { $_ eq 'foo' } $form->has_errors );
ok( !grep { $_ eq 'bar' } $form->has_errors );
ok( grep  { $_ eq 'string' } $form->has_errors );

ok( !$form->has_errors('foo') );
ok( !$form->has_errors('bar') );

ok( $form->has_errors('string') );

