package HTML::FormFu::Render::base;

use strict;

use HTML::FormFu::Attribute qw/ mk_accessors mk_attrs mk_attr_accessors /;
use HTML::FormFu::ObjectUtil qw/ form stash parent /;
use HTML::FormFu::Util qw/ _parse_args _get_elements process_attrs /;
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
        filename _elements /
);

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

    return $self->$method(@_);
}

sub xhtml {
    my ( $self, $filename ) = @_;

    $filename = $self->filename if !defined $filename;

    my %args = %{ $self->render_class_args };

    my $alloy = delete $args{TEMPLATE_ALLOY};
    $alloy = 1 if $ENV{HTML_FORMFU_TEMPLATE_ALLOY};
    require( $alloy ? 'Template/Alloy.pm' : 'Template.pm' );

    $args{INCLUDE_PATH} = 'root'  if !keys %args;
    $args{ENCODING}     = 'UTF-8' if !exists $args{ENCODING};

    $args{RELATIVE}  = 1;
    $args{RECURSION} = 1;

    my $package = $alloy ? 'Template::Alloy' : 'Template';
    my $template = $package->new( \%args );

    my $output;
    my %vars = (
        self          => $self,
        process_attrs => \&process_attrs,
    );

    $template->process( $filename, \%vars, \$output )
        or croak $template->error;

    return $output;
}

1;
