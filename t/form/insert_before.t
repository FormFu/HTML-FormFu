use strict;
use warnings;

use Test::More tests => 7;

use HTML::FormFu;

{
    my $form = HTML::FormFu->new;
    
    my $e1 = $form->element('Text')->name('foo');
    my $e2 = $form->element('Hidden')->name('foo');
    
    my $e3 = $e1->clone;
    
    $form->insert_before( $e3, $e1 );
    
    my $elems = $form->get_elements;
    
    is( scalar(@$elems), 3 );
    
    ok( $elems->[0] == $e3 );
    ok( $elems->[1] == $e1 );
    ok( $elems->[2] == $e2 );
}

# ensure elements only occur once

{
    my $form = HTML::FormFu->new;
    
    my $e1 = $form->element({ name => 'foo' });
    my $e2 = $form->element({ name => 'bar' });
    
    $form->insert_before( $e2, $e1 );
    
    my $elems = $form->get_elements;
    
    is( scalar(@$elems), 2 );
    
    ok( $elems->[0] == $e2 );
    ok( $elems->[1] == $e1 );
}
