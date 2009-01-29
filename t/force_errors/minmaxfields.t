use strict;
use warnings;

use Test::More tests => 26;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo')->constraint('MinMaxFields')
    ->others(qw/ bar baz boz/)->min(1)->max(2)->force_errors(1);
$form->element('Text')->name('bar');
$form->element('Text')->name('baz');
$form->element('Text')->name('boz');

# valid
{
    $form->process( {
            foo => 1,
            bar => '',
            baz => [2],
            boz => '',
        } );

    ok( !$form->has_errors, 'no real errors' );

    ok( !$form->has_errors('foo') );
    ok( !$form->has_errors('bar') );
    ok( !$form->has_errors('baz') );
    ok( !$form->has_errors('boz') );

    ok( @{ $form->get_errors( { name => 'foo', forced => 1 } ) } );
    ok( !@{ $form->get_errors( { name => 'bar', forced => 1 } ) } );
    ok( !@{ $form->get_errors( { name => 'baz', forced => 1 } ) } );
    ok( !@{ $form->get_errors( { name => 'boz', forced => 1 } ) } );
}

# valid
{
    $form->process( {
            foo => 1,
            bar => '',
            baz => '',
            boz => '',
        } );

    ok( !$form->has_errors, 'no real errors' );

    ok( !$form->has_errors('foo') );
    ok( !$form->has_errors('bar') );
    ok( !$form->has_errors('baz') );
    ok( !$form->has_errors('boz') );

    ok( @{ $form->get_errors( { name => 'foo', forced => 1 } ) } );
    ok( !@{ $form->get_errors( { name => 'bar', forced => 1 } ) } );
    ok( !@{ $form->get_errors( { name => 'baz', forced => 1 } ) } );
    ok( !@{ $form->get_errors( { name => 'boz', forced => 1 } ) } );
}

# invalid
{
    $form->process( {
            foo => 1,
            bar => '',
            baz => 2,
            boz => '22',
        } );

    ok( $form->has_errors );

    ok( $form->has_errors('foo') );
    ok( !$form->has_errors('bar') );
    ok( !$form->has_errors('baz') );
    ok( !$form->has_errors('boz') );
    
    ok( !@{ $form->get_errors( { name => 'bar', forced => 1 } ) } );
    ok( !@{ $form->get_errors( { name => 'baz', forced => 1 } ) } );
    ok( !@{ $form->get_errors( { name => 'boz', forced => 1 } ) } );
}
