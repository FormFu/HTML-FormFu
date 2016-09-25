use strict;
use warnings;

use Test::More tests => 9;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('Text')->name('foo')->constraint('CallbackOnce')->force_errors(1)
    ->callback(
    sub {
        return $_[0] eq 'a';
    } );

$form->element('Text')->name('bar')->constraint('CallbackOnce')->force_errors(1)
    ->callback(
    sub {
        return $_[0] eq 'b';
    } );

# valid
{
    $form->process( {
            foo => 'a',
            bar => 'b',
        } );

    ok( $form->submitted_and_valid );

    ok( !$form->has_errors('foo') );
    ok( !$form->has_errors('bar') );

    ok( @{ $form->get_errors( { name => 'foo', forced => 1 } ) } );
    ok( @{ $form->get_errors( { name => 'bar', forced => 1 } ) } );
}

# invalid
{
    $form->process( {
            foo => 'a',
            bar => 'c',
        } );

    ok( !$form->submitted_and_valid );

    ok( !$form->has_errors('foo') );
    ok( $form->has_errors('bar') );

    ok( @{ $form->get_errors( { name => 'foo', forced => 1 } ) } );
}
