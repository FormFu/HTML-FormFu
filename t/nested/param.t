use strict;
use warnings;

use Test::More tests => 11;

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

my @valid = $form->param;

ok( grep  { $_ eq 'foo.bar' } @valid );
ok( grep  { $_ eq 'foo.baz' } @valid );
ok( !grep { $_ eq 'foo.bag' } @valid );
ok( !grep { $_ eq 'foo.unknown' } @valid );

is( $form->param('foo.bar'), 1 );

my $bar = $form->param('foo.baz');
is( $bar, 2 );

my @bar = $form->param('foo.baz');
is_deeply( \@bar, [ 2, 3 ] );

ok( !$form->param('foo.bag') );
ok( !$form->param('foo.unknown') );

# new behaviour

# because a child has errors...
ok( !defined $form->param('foo') );

# with no errors...

$form->process( {
        'foo.bar'     => 1,
        'foo.baz'     => [ 2, 3 ],
        'foo.bag'     => 9,
        'foo.unknown' => 4,
    } );

is_deeply(
    $form->param('foo'),
    {
        bar => 1,
        baz => [ 2, 3 ],
        bag => 9,
    }
);

