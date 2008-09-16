use strict;
use warnings;

use Test::More tests => 6;

use HTML::FormFu::MultiForm;

my $multi = HTML::FormFu::MultiForm->new;

$multi->load_config_file('t-aggregated/multiform-misc/accessors.yml');

$multi->process;

{
    my $form = $multi->current_form;
    
    is( $form->auto_fieldset, 1 );
    
    is( $form->attrs->{id}, 'form' );
    is( $form->attrs->{onclick}, 'foo' );
}

{
    my $form = $multi->next_form;
    
    is( $form->auto_fieldset, 1 );
    
    is( $form->attrs->{id}, 'form' );
    
    ok( ! exists $form->attrs->{onclick} );
}
