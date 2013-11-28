package HTML::FormFu::Role::FormAndElementMethods;
use Moose::Role;

use HTML::FormFu::Attribute qw( mk_attr_output_accessors );
use HTML::FormFu::Util qw(
    require_class
    _merge_hashes
);
use Carp qw( croak );
use Scalar::Util qw( blessed refaddr );

__PACKAGE__->mk_attr_output_accessors(qw( title ));

sub _require_deflator {
    my ( $self, $type, $opt ) = @_;

    croak 'required arguments: $self, $type, \%options' if @_ != 3;

    eval { my %x = %$opt };
    croak "options argument must be hash-ref" if $@;

    my $class = $type;
    if ( not $class =~ s/^\+// ) {
        $class = "HTML::FormFu::Deflator::$class";
    }

    $type =~ s/^\+//;

    require_class($class);

    my $object = $class->new( {
            type   => $type,
            parent => $self,
        } );

    # handle default_args
    my $parent = $self->parent;

    if ( exists $parent->default_args->{deflators}{$type} ) {
        $opt
            = _merge_hashes( $parent->default_args->{deflators}{$type}, $opt, );
    }

    $object->populate($opt);

    return $object;
}

sub _require_filter {
    my ( $self, $type, $opt ) = @_;

    croak 'required arguments: $self, $type, \%options' if @_ != 3;

    eval { my %x = %$opt };
    croak "options argument must be hash-ref" if $@;

    my $class = $type;
    if ( not $class =~ s/^\+// ) {
        $class = "HTML::FormFu::Filter::$class";
    }

    $type =~ s/^\+//;

    require_class($class);

    my $object = $class->new( {
            type   => $type,
            parent => $self,
        } );

    # handle default_args
    my $parent = $self->parent;

    if ( exists $parent->default_args->{filters}{$type} ) {
        $opt = _merge_hashes( $parent->default_args->{filters}{$type}, $opt, );
    }

    $object->populate($opt);

    return $object;
}

sub _require_inflator {
    my ( $self, $type, $opt ) = @_;

    croak 'required arguments: $self, $type, \%options' if @_ != 3;

    eval { my %x = %$opt };
    croak "options argument must be hash-ref" if $@;

    my $class = $type;
    if ( not $class =~ s/^\+// ) {
        $class = "HTML::FormFu::Inflator::$class";
    }

    $type =~ s/^\+//;

    require_class($class);

    my $object = $class->new( {
            type   => $type,
            parent => $self,
        } );

    # handle default_args
    my $parent = $self->parent;

    if ( exists $parent->default_args->{inflators}{$type} ) {
        $opt
            = _merge_hashes( $parent->default_args->{inflators}{$type}, $opt, );
    }

    $object->populate($opt);

    return $object;
}

sub _require_validator {
    my ( $self, $type, $opt ) = @_;

    croak 'required arguments: $self, $type, \%options' if @_ != 3;

    eval { my %x = %$opt };
    croak "options argument must be hash-ref" if $@;

    my $class = $type;
    if ( not $class =~ s/^\+// ) {
        $class = "HTML::FormFu::Validator::$class";
    }

    $type =~ s/^\+//;

    require_class($class);

    my $object = $class->new( {
            type   => $type,
            parent => $self,
        } );

    # handle default_args
    my $parent = $self->parent;

    if ( exists $parent->default_args->{validators}{$type} ) {
        %$opt = ( %{ $parent->default_args->{validators}{$type} }, %$opt );
    }

    $object->populate($opt);

    return $object;
}

sub _require_transformer {
    my ( $self, $type, $opt ) = @_;

    croak 'required arguments: $self, $type, \%options' if @_ != 3;

    eval { my %x = %$opt };
    croak "options argument must be hash-ref" if $@;

    my $class = $type;
    if ( not $class =~ s/^\+// ) {
        $class = "HTML::FormFu::Transformer::$class";
    }

    $type =~ s/^\+//;

    require_class($class);

    my $object = $class->new( {
            type   => $type,
            parent => $self,
        } );

    # handle default_args
    my $parent = $self->parent;

    if ( exists $parent->default_args->{transformers}{$type} ) {
        $opt
            = _merge_hashes( $parent->default_args->{transformers}{$type}, $opt,
            );
    }

    $object->populate($opt);

    return $object;
}

sub _require_plugin {
    my ( $self, $type, $arg ) = @_;

    croak 'required arguments: $self, $type, \%options' if @_ != 3;

    eval { my %x = %$arg };
    croak "options argument must be hash-ref" if $@;

    my $abs = $type =~ s/^\+//;
    my $class = $type;

    if ( !$abs ) {
        $class = "HTML::FormFu::Plugin::$class";
    }

    $type =~ s/^\+//;

    require_class($class);

    my $plugin = $class->new( {
            type   => $type,
            parent => $self,
        } );

    $plugin->populate($arg);

    return $plugin;
}

sub get_deflator {
    my $self = shift;

    my $x = $self->get_deflators(@_);

    return @$x ? $x->[0] : ();
}

sub get_filter {
    my $self = shift;

    my $x = $self->get_filters(@_);

    return @$x ? $x->[0] : ();
}

sub get_constraint {
    my $self = shift;

    my $x = $self->get_constraints(@_);

    return @$x ? $x->[0] : ();
}

sub get_inflator {
    my $self = shift;

    my $x = $self->get_inflators(@_);

    return @$x ? $x->[0] : ();
}

sub get_validator {
    my $self = shift;

    my $x = $self->get_validators(@_);

    return @$x ? $x->[0] : ();
}

sub get_transformer {
    my $self = shift;

    my $x = $self->get_transformers(@_);

    return @$x ? $x->[0] : ();
}

sub get_plugin {
    my $self = shift;

    my $x = $self->get_plugins(@_);

    return @$x ? $x->[0] : ();
}

sub model_config {
    my ( $self, $config ) = @_;

    $self->{model_config} ||= {};

    $self->{model_config} = _merge_hashes( $self->{model_config}, $config );

    return $self->{model_config};
}

sub _string_equals {
    my ( $a, $b ) = @_;

    return blessed($b)
        ? ( refaddr($a) eq refaddr($b) )
        : ( "$a" eq "$b" );
}

sub _object_equals {
    my ( $a, $b ) = @_;

    return blessed($b)
        ? ( refaddr($a) eq refaddr($b) )
        : undef;
}

1;
