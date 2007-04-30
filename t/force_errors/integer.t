use strict;
use warnings;

use Test::More tests => 8;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->element('text')->name('foo')->constraint('Integer')->force_errors(1);
$form->element('text')->name('bar')->constraint('Integer')->force_errors(1);

{
    $form->process( {
            foo => '12',
            bar => "12\n",
        } );

    ok( $form->has_errors('foo') );
    ok( $form->has_errors('bar') );
    
    ok( !$form->get_errors('foo')->[0]{forced} );
    ok( $form->get_errors('bar')->[0]{forced} );
}

{
    $form->process( {
            foo => 0,
            bar => "0\n",
        } );

    ok( $form->has_errors('foo') );
    ok( $form->has_errors('bar') );
    
    ok( !$form->get_errors('foo')->[0]{forced} );
    ok( $form->get_errors('bar')->[0]{forced} );
}
