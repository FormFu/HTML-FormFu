use strict;
use warnings;

use Test::More tests => 6;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo')->constraint('Integer')->force_errors(1);
$form->element('text')->name('bar')->constraint('Integer')->force_errors(1);

{
    $form->process( {
            foo => '12',
            bar => "12\n",
        } );

    ok( !$form->has_errors('foo') );
    ok( $form->has_errors('bar') );
    
    ok( $form->get_errors({ name => 'foo', forced => 1 }) );
}

{
    $form->process( {
            foo => 0,
            bar => "0\n",
        } );

    ok( !$form->has_errors('foo') );
    ok( $form->has_errors('bar') );
    
    ok( $form->get_errors({ name => 'foo', forced => 1 }) );
}
