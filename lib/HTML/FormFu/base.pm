package HTML::FormFu::base;
use strict;
use Class::C3;

use HTML::FormFu::Util qw/ process_attrs /;
use Carp qw/ croak /;

our $SHARE_DIR;
our $SHARE_ERROR;

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
    my ( $self, $args ) = @_;

    $args ||= {};

    $args->{filename}    = $self->filename    if !exists $args->{filename};
    $args->{render_data} = $self->render_data if !exists $args->{render_data};

    my $form      = $self->form;
    my $share_dir = _share_dir();

    my %args = %{ $self->tt_args };

    if ( defined $share_dir ) {

        # add $share_dir to the end of INCLUDE_PATH

        $args{INCLUDE_PATH}
            = exists $args{INCLUDE_PATH}
            ? ref $args{INCLUDE_PATH} eq 'ARRAY'
                ? [ @{ $args{INCLUDE_PATH} }, $share_dir ]
                : [ $args{INCLUDE_PATH}, $share_dir ]
            : [$share_dir];
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
        self          => $args->{render_data},
        process_attrs => \&process_attrs,
    );

    if ( !$template->process( $args->{filename}, \%vars, \$output ) ) {

        my $error = $template->error;

        if ( $error->type() eq 'file' && $error =~ /not found/i ) {
            croak <<ERROR;
$error
The template files should have been installed somewhere in \@INC as part of
the installation process.
If you're using Catalyst, see Catalyst::Helper::HTML::FormFu.
Alternatively, you can create a local copy of the files by running 
    `html_formfu_deploy.pl`.
Then set \$form->tt_args->{INCLUDE_PATH} to point to the template directory.
ERROR

        }
        else {
            croak $error;
        }
    }

    return $output;
}

sub _share_dir {

    return $SHARE_DIR if defined $SHARE_DIR;

    return if $SHARE_ERROR;

    eval {
        require 'File/ShareDir.pm';
        require 'File/Spec.pm';

        # dist_dir() doesn't reliably return the directory our files are in.
        # find the path of one of our files, then get the directory from that

        my $path = File::ShareDir::dist_file( 'HTML-FormFu',
            'templates/tt/xhtml/form' );

        my ( $volume, $dirs, $file ) = File::Spec->splitpath($path);

        $SHARE_DIR = File::Spec->catpath( $volume, $dirs, '' );
    };

    if ($@) {
        $SHARE_DIR   = undef;
        $SHARE_ERROR = 1;
        return;
    }

    return $SHARE_DIR;
}

1;
