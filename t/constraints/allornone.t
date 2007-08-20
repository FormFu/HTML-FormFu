use strict;
use warnings;

use Test::More tests => 7;

use HTML::FormFu;

my $form = HTML::FormFu->new->indicator( sub {1} );

$form->element('Text')->name('foo')->constraint('AllOrNone')
    ->others(qw/ bar baz bif /);

$form->element('Text')->name('bar');
$form->element('Text')->name('baz');
$form->element('Text')->name('bif');

# Valid
{
    $form->process( {
            foo => 1,
            bar => 'a',
            baz => [2],
            bif => [ 3, 4 ],
        } );

    ok( !$form->has_errors );
}

# Valid
{
    $form->process( {} );

    ok( !$form->has_errors );
}

# Invalid
{
    $form->process( {
            foo => 1,
            bar => '',
            baz => [2],
            bif => [ 3, 4 ],
        } );

    ok( $form->has_errors );

    ok( $form->valid('foo') );
    ok( $form->has_errors('bar') );
    ok( $form->valid('baz') );
    ok( $form->valid('bif') );
}
