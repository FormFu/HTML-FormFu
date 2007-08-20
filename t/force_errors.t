use strict;
use warnings;

use Test::More tests => 15;

use HTML::FormFu;

my $form = HTML::FormFu->new->force_errors(1);

$form->element('Text')->name('foo')->constraint('Integer');
$form->element('Text')->name('bar')->constraint('Integer');

{
    $form->process( {
            foo => '1',
            bar => '0',
        } );

    ok( !$form->has_errors, 'has no real errors' );

    ok( !$form->has_errors('foo') );
    ok( !$form->has_errors('bar') );

    ok( $form->get_errors( { name => 'foo', forced => 1 } ) );
    ok( $form->get_errors( { name => 'bar', forced => 1 } ) );

    ok( $form->valid('foo') );
    ok( $form->valid('bar') );

    ok( $form->submitted_and_valid );
}

{
    $form->process( {
            foo => 0,
            bar => "0\n",
        } );

    ok( $form->has_errors );

    ok( !$form->has_errors('foo') );
    ok( $form->has_errors('bar') );

    ok( $form->get_errors( { name => 'foo', forced => 1 } ) );

    ok( $form->valid('foo') );
    ok( !$form->valid('bar') );

    ok( !$form->submitted_and_valid );
}
