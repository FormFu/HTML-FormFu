use strict;
use warnings;

use Test::More tests => 4;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $foo = $form->element('Text')->name('foo');

$foo->constraint('DateTime')->parser( { strptime => '%d/%m/%Y' } );

# valid
{
    $form->process( { foo => '31/12/2006' } );
    
    ok( $form->submitted_and_valid );
    
    is( $form->params->{foo}, '31/12/2006' );
}

# invalid
{
    $form->process( { foo => '12/31/2006' } );
    
    ok( !$form->submitted_and_valid );
    
    ok( $form->has_errors('foo') );
}
