use strict;
use warnings;
use lib 'lib';
use HTML::FormFu;
use HTML::Widget;
use CGI::FormBuilder;
use Benchmark qw( cmpthese );

my $formfu  = formfu();
my $widget  = widget();
my $builder = builder();

#print $formfu;
#print "\n\n**********\n\n";
#print $widget->process;
#print "\n\n**********\n\n";
#print $builder->render;

# make sure TT has loaded/cached everything
my $output = "$formfu";

cmpthese(
    500,
    {
        'HTML::FormFu' => sub {
            $output = "$formfu";
        },
        'HTML::Widget' => sub {
            $output = $widget->process->as_xml;
        },
        'CGI::FormBuilder' => sub {
            $output = $builder->render;
        },
    }
);

sub formfu {
    my $form = HTML::FormFu->new;
    
    $form->load_from_config('tobias.yml');
    
    return $form;
}

sub widget {
    my $form = HTML::Widget->new;
    
    $form->element( "Textfield", "motto" )->label("Motto:")->maxlength(80);
    $form->element( "Textarea", "about" )->label("About me:")->rows(6)->cols(50);
    
    $form->element( "Textfield", "city" )->label("City:")->maxlength(32);
    $form->element( "Select", "zip_codes" )->label("Zipcode:")
        ->comment("Select how many zipcode digits you want to display to other users.");
    
    $form->element( "Textfield", "daystart" )->label("My morning starts with:")
        ->maxlength(255);
    $form->element( "Textfield", "" )->label("")->maxlength();
    $form->element( "Textfield", "" )->label("")->maxlength();
    $form->element( "Textfield", "" )->label("")->maxlength();
    $form->element( "Textfield", "" )->label("")->maxlength();
    
    $form->element( "Select", "" )->label("");
    
    $form->element( "Submit", "submit" );
    
    return $form;
}

sub builder {
    my $form = CGI::FormBuilder->new;
    
    for (1..10) {
        $form->field(
            name  => "text$_",
            size  => 10,
            label => "text & $_",
        );
    }
    
    $form->field(
        name    => "select",
        options => [ 1907 .. 2007 ],
        value   => 2007,
        
    );
    
    return $form;
}
