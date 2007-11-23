use strict;
use warnings;

use Test::More tests => 7;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->auto_fieldset( { nested_name => 'foo' } );

$form->element('Text')->name('bar')->constraint('Number');
$form->element('Text')->name('baz')->constraint('Number');
$form->element('Text')->name('bag')->constraint('Number');

$form->process( {
        'foo.bar'     => 1,
        'foo.baz'     => [ 2, 3 ],
        'foo.bag'     => 'yada',
        'foo.unknown' => 4,
    } );

is_deeply(
    [ sort( $form->valid ) ],
    [qw/
        foo.bar
        foo.baz
    /]
);

ok( $form->valid('foo.bar') );
ok( $form->valid('foo.baz') );
ok( !$form->valid('foo.bag') );
ok( !$form->valid('foo.unknown') );

# new behaviour

# because a child has errors...
ok( !$form->valid('foo') );

# with no errors...

$form->process( {
        'foo.bar'     => 1,
        'foo.baz'     => [ 2, 3 ],
        'foo.bag'     => 9,
        'foo.unknown' => 4,
    } );

ok( $form->valid('foo') );

