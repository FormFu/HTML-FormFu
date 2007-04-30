use strict;
use warnings;

use Test::More tests => 7;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo')->constraint('MinMaxFields')->others(qw/ bar baz boz/)->min(1)->max(2);
$form->element('text')->name('bar');
$form->element('text')->name('baz');
$form->element('text')->name('boz');

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
    
    ok( ! $form->valid('foo') );
    ok( $form->valid('bar') );
    ok( $form->valid('baz') );
    ok( $form->valid('boz') );
}
