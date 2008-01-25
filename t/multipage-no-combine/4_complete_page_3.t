use strict;
use warnings;

use Test::More tests => 6;

use HTML::FormFu::MultiPage;

# submit page 1

my $yaml_file = 't/multipage-no-combine/multipage.yml';
my $page2_hidden_value;

{
    my $multi = HTML::FormFu::MultiPage->new;
    
    $multi->load_config_file( $yaml_file );
    
    $multi->process({
        foo    => 'abc',
        submit => 'Submit',
    });
    
    ok( $multi->current_form->submitted_and_valid );
    
    my $page2 = $multi->next_form;
    
    my $hidden_field = $page2->get_field({ name => 'crypt' });
    
    $page2_hidden_value = $hidden_field->default;
}

# submit page 2

my $page3_hidden_value;

{
    my $multi = HTML::FormFu::MultiPage->new;
    
    $multi->load_config_file( $yaml_file );
    
    $multi->process({
        crypt  => $page2_hidden_value,
        bar    => 'def',
        submit => 'Submit',
    });
    
    my $form = $multi->current_form;
    
    ok( $form->submitted_and_valid );
    
    my $page3 = $multi->next_form;
    
    my $hidden_field = $page3->get_field({ name => 'crypt' });
    
    $page3_hidden_value = $hidden_field->default;
}

# submit page 3

{
    my $multi = HTML::FormFu::MultiPage->new;
    
    $multi->load_config_file( $yaml_file );
    
    $multi->process({
        crypt  => $page3_hidden_value,
        baz    => 'ghi',
        submit => 'Submit',
    });
    
    ok( $multi->complete );
    
    my $form = $multi->current_form;
    
    ok( $form->submitted_and_valid );
    
    my $params = $form->params;
    
    is( $params->{baz},    'ghi' );
    is( $params->{submit}, 'Submit' );
}

