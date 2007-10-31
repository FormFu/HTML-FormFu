package HTML::FormFu::Render::base;

use strict;

use HTML::FormFu::Attribute qw/ mk_accessors mk_attrs mk_attr_accessors /;
use HTML::FormFu::ObjectUtil qw/ form stash parent /;
use HTML::FormFu::Util qw/ _parse_args _get_elements process_attrs /;
use File::ShareDir qw/ dist_file /;
use File::Spec;
use Scalar::Util qw/ refaddr /;
use Carp qw/ croak /;

use overload
    'eq' => sub { refaddr $_[0] eq refaddr $_[1] },
    '==' => sub { refaddr $_[0] eq refaddr $_[1] },
    '""'     => sub { return shift->output },
    bool     => sub {1},
    fallback => 1;

__PACKAGE__->mk_attrs(qw/ attributes /);

__PACKAGE__->mk_accessors(
    qw/ render_class_args render_class_suffix render_method
        filename _elements _output_processors /
);

our $SHARE_DIR;

eval {
    # dist_dir() doesn't reliably return the directory our files are in.
    # find the path of one of our files, then get the directory from that
    
    my $path = dist_file( 'HTML-FormFu', 'templates/tt/xhtml/form' );
    
    my ( $volume, $dirs, $file ) = File::Spec->splitpath( $path );
    
    $SHARE_DIR = File::Spec->catpath( $volume, $dirs, '' );
};

sub new {
    my $class = shift;

    my %attrs;
    eval { %attrs = %{ $_[0] } if @_ };
    croak "attributes argument must be a hashref" if $@;

    my $self = bless \%attrs, $class;

    return $self;
}

sub elements {
    my $self = shift;
    my %args = _parse_args(@_);

    my @elements = @{ $self->{_elements} };

    return _get_elements( \%args, \@elements );
}

sub element {
    my $self = shift;

    my $e = $self->elements(@_);

    return @$e ? $e->[0] : ();
}

sub fields {
    my $self = shift;
    my %args = _parse_args(@_);

    my @e = map { $_->is_field ? $_ : @{ $_->fields } } @{ $self->{_elements} };

    return _get_elements( \%args, \@e );
}

sub field {
    my $self = shift;

    my $f = $self->fields(@_);

    return @$f ? $f->[0] : ();
}

sub output {
    my $self = shift;

    my $method = $self->render_method;

    my $output = $self->$method(@_);

    for my $proc ( @{ $self->form->get_output_processors } ) {
        $output = $proc->process($output);
    }

    return $output;
}

sub xhtml {
    my ( $self, $filename ) = @_;

    $filename = $self->filename if !defined $filename;

    my %args = %{ $self->render_class_args };

    my $alloy = delete $args{TEMPLATE_ALLOY};
    $alloy = 1 if $ENV{HTML_FORMFU_TEMPLATE_ALLOY};
    require( $alloy ? 'Template/Alloy.pm' : 'Template.pm' );

    if ( defined $SHARE_DIR ) {
        # add $SHARE_DIR to the end of INCLUDE_PATH

        $args{INCLUDE_PATH} =
            exists $args{INCLUDE_PATH}
                ?  ref $args{INCLUDE_PATH} eq 'ARRAY'
                    ? [ @{ $args{INCLUDE_PATH} }, $SHARE_DIR ]
                    : [ $args{INCLUDE_PATH}, $SHARE_DIR ]
                : [ $SHARE_DIR ];
    }

    $args{ENCODING}  = 'UTF-8' if !exists $args{ENCODING};
    $args{RELATIVE}  = 1;
    $args{RECURSION} = 1;

    my $package = $alloy ? 'Template::Alloy' : 'Template';
    my $template = $package->new( \%args );

    my $output;
    my %vars = (
        self          => $self,
        process_attrs => \&process_attrs,
    );

    if (!$template->process( $filename, \%vars, \$output )) {
        
        my $error = $template->error;
        my $type  = 'file';
        
        if ( !$alloy ) {
            require "Template/Constants.pm";
            $type = Template::Constants::ERROR_FILE();
        }
        
        if ( $error->type() eq $type ) {
            croak <<ERROR;
Template file not found: '$filename'.
The template files should have been installed somewhere in @INC as part of
the installation process, please report this bug.
See Catalyst::Helper::HTML::FormFu if you're using Catalyst.
Alternatively, you can create a local copy of the files by running 
    `html_formfu_deploy.pl`.
Then set \$form->render_class_args->{INCLUDE_PATH} to point to that location.
Template error: '$error'
ERROR

        }
        else {
           croak $error;
        }
    }

    return $output;
}

1;
