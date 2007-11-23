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
#exit;

# make sure TT has loaded/cached everything
my $output = "$formfu";

cmpthese(
    100,
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
    
    $form->tt_args({
        TEMPLATE_ALLOY => 1,
        COMPILE_DIR    => 'benchmarks/cache',
        COMPILE_PERL   => 1,
        INCLUDE_PATH   => 'share/templates/tt/xhtml',
    });
    
    for (1..10) {
        $form->element({ type => 'Text', name => "text$_" })
            ->label("text & $_")
            ->size(10);
    }
    
    $form->element({ type => 'Select', name => 'select' })
        ->values( [1907 .. 2007] )
        ->default(2007);
    
    $form->element({ type => 'Submit', name => 'submit' });
    
    return $form;
}

sub widget {
    my $form = HTML::Widget->new;
    
    for (1..10) {
        $form->element( "Textfield", "text$_" )
            ->label("text & $_")
            ->size(10);
    }
    
    $form->element( "Select", "select" )
        ->options( map { $_, $_ } 1907 .. 2007 )
        ->selected(2007);
    
    $form->element( "Submit", "submit" );
    
    return $form;
}

sub builder {
    my $form = CGI::FormBuilder->new;
    
    for (1..10) {
        $form->field(
            name  => "text$_",
            size  => 10,
            label => "text &amp; $_",
        );
    }
    
    $form->field(
        name    => "select",
        options => [ 1907 .. 2007 ],
        value   => 2007,
        
    );
    
    return $form;
}
