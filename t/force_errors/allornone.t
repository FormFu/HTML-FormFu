use strict;
use warnings;

use Test::More tests => 24;

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

    ok( $form->submitted_and_valid );

    ok( !$form->has_errors('foo') );
    ok( !$form->has_errors('bar') );
    ok( !$form->has_errors('baz') );
    ok( !$form->has_errors('bif') );
    
    ok( @{ $form->get_errors( { name => 'foo', forced => 1 } ) } );
    ok( @{ $form->get_errors( { name => 'bar', forced => 1 } ) } );
    ok( @{ $form->get_errors( { name => 'baz', forced => 1 } ) } );
    ok( @{ $form->get_errors( { name => 'bif', forced => 1 } ) } );
}

# Valid
{
    $form->process( {} );

    ok( $form->submitted_and_valid );

    ok( !$form->has_errors('foo') );
    ok( !$form->has_errors('bar') );
    ok( !$form->has_errors('baz') );
    ok( !$form->has_errors('bif') );
    
    ok( @{ $form->get_errors( { name => 'foo', forced => 1 } ) } );
    ok( @{ $form->get_errors( { name => 'bar', forced => 1 } ) } );
    ok( @{ $form->get_errors( { name => 'baz', forced => 1 } ) } );
    ok( @{ $form->get_errors( { name => 'bif', forced => 1 } ) } );
}

# Invalid
{
    $form->process( {
            foo => 1,
            bar => '',
            baz => [2],
            bif => [ 3, 4 ],
        } );

    ok( !$form->submitted_and_valid );

    ok( !$form->has_errors('foo') );
    ok( $form->has_errors('bar') );
    ok( !$form->has_errors('baz') );
    ok( !$form->has_errors('bif') );

    ok( @{ $form->get_errors( { name => 'bar', forced => 1 } ) } );
}
