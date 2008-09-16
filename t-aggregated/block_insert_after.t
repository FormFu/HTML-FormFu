use strict;
use warnings;

use Test::More tests => 7;

use HTML::FormFu;

{
    my $form = HTML::FormFu->new;
    
    my $fs = $form->element('Fieldset');
    my $e1 = $fs->element('Text')->name('foo');
    my $e2 = $fs->element('Hidden')->name('foo');
    
    my $e3 = $e1->clone;
    
    $fs->insert_after( $e3, $e1 );
    
    my $elems = $fs->get_elements;
    
    is( scalar(@$elems), 3 );
    
    ok( $elems->[0] == $e1 );
    ok( $elems->[1] == $e3 );
    ok( $elems->[2] == $e2 );
}

# ensure elements only occur once

{
    my $form = HTML::FormFu->new;
    
    my $fs = $form->element('Fieldset');
    my $e1 = $fs->element({ name => 'foo' });
    my $e2 = $fs->element({ name => 'bar' });
    
    $fs->insert_after( $e1, $e2 );
    
    my $elems = $fs->get_elements;
    
    is( scalar(@$elems), 2 );
    
    ok( $elems->[0] == $e2 );
    ok( $elems->[1] == $e1 );
}
