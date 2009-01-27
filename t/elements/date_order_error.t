use strict;
use warnings;

use Test::More tests => 2;

use HTML::FormFu;

{
    my $form = HTML::FormFu->new;
    
    eval {
        my $element = $form->element('Date');
        $element->name('date');
        $element->field_order( [ qw/ month day foo / ] );
         $form->process;
    };
    
    ok($@);
}

{
    my $form = HTML::FormFu->new;
    
    eval {
        my $element = $form->element('Date');
        $element->name('date');
        $form->process;
        $element->field_order( [qw/ month month day / ] )->value('01-01-2007');
    };
    
    ok($@);
}
