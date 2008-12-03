use strict;
use warnings;

use Test::More tests => 8;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo')->constraint('MinMaxFields')
    ->others(qw/ bar baz boz/)->min(1)->max(2);
$form->element('Text')->name('bar');
$form->element('Text')->name('baz');
$form->element('Text')->name('boz');

# Valid
{
    $form->process( {
            foo => 1,
            bar => '',
            baz => [2],
            boz => '',
        } );

    ok( !$form->has_errors );

    $form->process( {
            foo => 1,
            bar => '',
            baz => '',
            boz => '',
        } );

    ok( !$form->has_errors );
}

# Invalid
{
    $form->process( {
            foo => 1,
            bar => '',
            baz => 2,
            boz => '22',
        } );

    ok( $form->has_errors );

    ok( !$form->valid('foo') );
    ok( $form->valid('bar') );
    ok( $form->valid('baz') );
    ok( $form->valid('boz') );
}

{
    # Test setting default for max when others is a single element
    my $form = HTML::FormFu->new;
    
    $form->element('Text')->name('foo')->constraint('MinMaxFields')
        ->others('bar');
    $form->element('Text')->name('bar');
    
    {
        $form->process( {
                foo => 1,
                bar => '',
        } );
    
        ok( !$form->has_errors );
    }
}