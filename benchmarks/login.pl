use strict;
use warnings;
use lib 'lib';
use HTML::FormFu;
use HTML::Widget;
use CGI::FormBuilder;
use HTML::FormFu::FakeQuery;
use YAML::Syck qw( LoadFile );
use Benchmark qw( cmpthese );

my $formfu_file  = 'benchmarks/login-formfu.yml';
my $builder_file = 'benchmarks/login-formbuilder.conf';

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

#eval "use Devel::Profiler";
#Devel::Profiler::init();
#$output = "$formfu";

print "No submit\n";

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

my $query = HTML::FormFu::FakeQuery->new(
    $formfu,
    {
        _submitted => 1,
        username   => 'only me',
        password   => 'secret',
        _submit    => 'Submit',
    });

print "\nConstruction + submission\n";

cmpthese(
    500,
    {
        'HTML::FormFu' => sub {
            my $formfu = HTML::FormFu->new
                ->load_config_file($formfu_file);
            
            $formfu->process($query);
            
            die 'formfu not submitted'
                if ! $formfu->submitted_and_valid;
            
            $output = "$formfu";
        },
        'HTML::Widget' => sub {
            my $widget = widget();
            
            $output = $widget->process->as_xml;
        },
        'CGI::FormBuilder' => sub {
            my $builder = CGI::FormBuilder->new(
                source => $builder_file,
                params => $query );
            
            die 'builder not submitted'
                if ! $builder->submitted || ! $builder->validate;
            
            $output = $builder->confirm;
        },
    }
);

sub formfu {
    my $form = HTML::FormFu->new;
    
    $form->load_config_file( $formfu_file );
    
    return $form;
}

sub widget {
    my $form = HTML::Widget->new;
    
    $form->element( "Textfield", "username" )
        ->label("Username")
        ->size(10);
    
    $form->element( "Password", "password" )
        ->label("Password")
        ->size(10);
    
    $form->element( "Submit", "_submit" );

    $form->constraint( "All", "username", "password" );
    
    return $form;
}

sub builder {
    my $form = CGI::FormBuilder->new(
        source => $builder_file );
    
    return $form;
}
