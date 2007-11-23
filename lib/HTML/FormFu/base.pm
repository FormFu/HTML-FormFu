package HTML::FormFu::base;
use strict;
use Class::C3;

use HTML::FormFu::Util qw/ process_attrs /;
use Carp qw/ croak /;

sub render {
    my $self = shift;
    
    my $render_method = $self->render_method;
    
    $render_method = $ENV{HTML_FORMFU_RENDER_METHOD}
        if defined $ENV{HTML_FORMFU_RENDER_METHOD}
            && length $ENV{HTML_FORMFU_RENDER_METHOD};
    
    my $output = $self->$render_method(@_);
    
    for my $proc ( @{ $self->form->get_output_processors } ) {
        $output = $proc->process($output);
    }
    
    return $output;
}

sub tt {
    my $self = shift;
    
    my $filename = @_ ? shift : $self->filename; 
    
    my $form      = $self->form;
    my $share_dir = $form->share_dir;
    
    my %args = %{ $self->tt_args };
    
    if ( defined $share_dir ) {
        # add $share_dir to the end of INCLUDE_PATH

        $args{INCLUDE_PATH} =
            exists $args{INCLUDE_PATH}
                ?  ref $args{INCLUDE_PATH} eq 'ARRAY'
                    ? [ @{ $args{INCLUDE_PATH} }, $share_dir ]
                    : [ $args{INCLUDE_PATH}, $share_dir ]
                : [ $share_dir ];
    }
    
    $args{ENCODING}  = 'UTF-8' if !exists $args{ENCODING};
    $args{RELATIVE}  = 1;
    $args{RECURSION} = 1;
    
    my $tt_module = $form->tt_module;
    
    $tt_module = $ENV{HTML_FORMFU_TT_MODULE}
        if defined $ENV{HTML_FORMFU_TT_MODULE}
            && length $ENV{HTML_FORMFU_TT_MODULE};
    
    my $class = $tt_module;
    $class =~ s|::|/|g;
    $class .= ".pm";
    
    if ( !exists $::INC{$class} ) {
        eval { require $class };
        croak $@ if $@;
    }
    
    my $template = $tt_module->new( \%args );
    
    my $output;
    my %vars = (
        self          => $self->render_data,
        process_attrs => \&process_attrs,
    );
    
    if (!$template->process( $filename, \%vars, \$output )) {
        
        my $error = $template->error;
        
        if ( $error->type() eq 'file' && $error =~ /not found/ ) {
            croak <<ERROR;
$error
The template files should have been installed somewhere in \@INC as part of
the installation process, please report this bug.
See Catalyst::Helper::HTML::FormFu if you're using Catalyst.
Alternatively, you can create a local copy of the files by running 
    `html_formfu_deploy.pl`.
Then set \$form->tt_args->{INCLUDE_PATH} to point to that location.
ERROR

        }
        else {
           croak $error;
        }
    }

    return $output;
}

1;
