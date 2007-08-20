use strict;
use warnings;

use Test::More tests => 13;

use HTML::FormFu;

my $form = HTML::FormFu->new->indicator( sub {1} );

$form->element('Text')->name('foo')->constraint('AllOrNone')
    ->others(qw/ bar baz bif /)->force_errors(1);

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

    ok( !$form->has_errors('foo') );
    ok( !$form->has_errors('bar') );
    ok( !$form->has_errors('baz') );
    ok( !$form->has_errors('bif') );
}

# Valid
{
    $form->process( {} );

    ok( !$form->has_errors('foo') );
    ok( !$form->has_errors('bar') );
    ok( !$form->has_errors('baz') );
    ok( !$form->has_errors('bif') );
}

# Invalid
{
    $form->process( {
            foo => 1,
            bar => '',
            baz => [2],
            bif => [ 3, 4 ],
        } );

    ok( !$form->has_errors('foo') );
    ok( $form->has_errors('bar') );
    ok( !$form->has_errors('baz') );
    ok( !$form->has_errors('bif') );

    ok( $form->get_errors( { name => 'bar', forced => 1 } ) );
}
