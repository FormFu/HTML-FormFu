package HTML::FormFu::ObjectUtil;

use strict;
use Exporter qw( import );

use HTML::FormFu::Util qw(
    _parse_args             require_class
    _get_elements
    _filter_components      _merge_hashes
);
use Clone ();
use Config::Any;
use Clone ();
use Data::Visitor::Callback;
use File::Spec;
use Scalar::Util qw( refaddr reftype weaken blessed );
use List::MoreUtils qw( none uniq );
use Carp qw( croak );

our @EXPORT_OK = (
    qw(
        populate
        deflator
        load_config_file        load_config_filestem
        form
        get_parent
        insert_before           insert_after
        clone
        name
        stash
        constraints_from_dbic
        parent
        nested_name             nested_names
        remove_element
        _string_equals          _object_equals
        ),
);

sub populate {
    my ( $self, $arg_ref ) = @_;

    croak "argument to populate() must be a hash-ref"
        if reftype( $arg_ref ) ne 'HASH';

    # shallow clone the args so we don't stomp on them
    my %args = %$arg_ref;

    # notes for @keys...
    # 'options', 'values', 'value_range' is for _Group elements,
    # to ensure any 'empty_first' value gets set first

    my @keys = qw(
        default_args
        auto_fieldset
        load_config_file
        element elements
        default_values
        filter              filters
        constraint          constraints
        inflator            inflators
        deflator            deflators
        query
        validator           validators
        transformer         transformers
        plugins
        options
        values
        value_range
    );

    my %defer;
    for (@keys) {
        $defer{$_} = delete $args{$_} if exists $args{$_};
    }

    eval {
        map { $self->$_( $args{$_} ) } keys %args;

        map      { $self->$_( $defer{$_} ) }
            grep { exists $defer{$_} } @keys;
    };
    croak $@ if $@;

    return $self;
}

sub load_config_file {
    my ( $self, @files ) = @_;

    my $use_stems = 0;

    return _load_config( $self, $use_stems, @files );
}

sub load_config_filestem {
    my ( $self, @files ) = @_;

    my $use_stems = 1;

    return _load_config( $self, $use_stems, @files );
}

sub _load_config {
    my ( $self, $use_stems, @filenames ) = @_;

    if ( scalar @filenames == 1 && ref $filenames[0] eq 'ARRAY' ) {
        @filenames = @{ $filenames[0] };
    }

    my $config_callback = $self->config_callback;
    my $data_visitor;

    if ( defined $config_callback ) {
        $data_visitor = Data::Visitor::Callback->new( %$config_callback,
            ignore_return_values => 1, );
    }

    my $config_any_arg    = $use_stems ? 'stems'      : 'files';
    my $config_any_method = $use_stems ? 'load_stems' : 'load_files';

    my @config_file_path;

    if ( my $config_file_path = $self->config_file_path ) {

        if ( ref $config_file_path eq 'ARRAY' ) {
            push @config_file_path, @$config_file_path;
        }
        else {
            push @config_file_path, $config_file_path;
        }
    }
    else {
        push @config_file_path, File::Spec->curdir;
    }

    for my $file (@filenames) {
        my $loaded = 0;
        my $fullpath;

        foreach my $config_file_path (@config_file_path) {

            if ( defined $config_file_path
                && !File::Spec->file_name_is_absolute($file) )
            {
                $fullpath = File::Spec->catfile( $config_file_path, $file );
            }
            else {
                $fullpath = $file;
            }

            my $config = Config::Any->$config_any_method( {
                    $config_any_arg => [$fullpath],
                    use_ext         => 1,
                    driver_args => { General => { -UTF8 => 1 }, },
                } );

            next if !@$config;

            $loaded = 1;
            my ( $filename, $filedata ) = %{ $config->[0] };

            _load_file( $self, $data_visitor, $filedata );
            last;
        }
        croak "config file '$file' not found" if !$loaded;
    }

    return $self;
}

sub _load_file {
    my ( $self, $data_visitor, $data ) = @_;

    if ( defined $data_visitor ) {
        $data_visitor->visit($data);
    }

    for my $config ( ref $data eq 'ARRAY' ? @$data : $data ) {
        $self->populate( Clone::clone($config) );
    }

    return;
}

sub form {
    my ($self) = @_;

    # micro optimization! this method's called a lot, so access
    # parent hashkey directly, instead of calling parent()
    while ( defined( my $parent = $self->{parent} ) ) {
        $self = $parent;
    }

    return $self;
}

sub clone {
    my ($self) = @_;

    my %new = %$self;

    $new{_elements}    = [ map { $_->clone } @{ $self->_elements } ];
    $new{attributes}   = Clone::clone( $self->attributes );
    $new{tt_args}      = Clone::clone( $self->tt_args );
    $new{model_config} = Clone::clone( $self->model_config );

    if ( $self->can('_plugins') ) {
        $new{_plugins} = [ map { $_->clone } @{ $self->_plugins } ];
    }

    $new{languages}
        = ref $self->languages
        ? Clone::clone( $self->languages )
        : $self->languages;

    $new{default_args} = $self->default_args;

    my $obj = bless \%new, ref $self;

    map { $_->parent($obj) } @{ $new{_elements} };

    return $obj;
}

sub name {
    my $self = shift;

    croak 'cannot use name() as a setter' if @_;

    return $self->parent->name;
}

sub nested_name {
    my $self = shift;

    croak 'cannot use nested_name() as a setter' if @_;

    return $self->parent->nested_name;
}

sub nested_names {
    my $self = shift;

    croak 'cannot use nested_names() as a setter' if @_;

    return $self->parent->nested_names;
}

sub stash {
    my $self = shift;

    $self->{stash} = {} if not exists $self->{stash};
    return $self->{stash} if !@_;

    my %attrs = ( @_ == 1 ) ? %{ $_[0] } : @_;

    $self->{stash}->{$_} = $attrs{$_} for keys %attrs;

    return $self;
}

sub constraints_from_dbic {
    my ( $self, $source, $map ) = @_;

    $map ||= {};

    $source = _result_source($source);

    for my $col ( $source->columns ) {
        _add_constraints( $self, $col, $source->column_info($col) );
    }

    for my $col ( keys %$map ) {
        my $source = _result_source( $map->{$col} );

        _add_constraints( $self, $col, $source->column_info($col) );
    }

    return $self;
}

sub _result_source {
    my ($source) = @_;

    if ( blessed $source ) {
        $source = $source->result_source;
    }

    return $source;
}

sub _add_constraints {
    my ( $self, $col, $info ) = @_;

    return if !defined $self->get_field($col);

    return if !defined $info->{data_type};

    my $type = lc $info->{data_type};

    if ( $type =~ /(char|text|binary)\z/ && defined $info->{size} ) {

        # char, varchar, *text, binary, varbinary
        _add_constraint_max_length( $self, $col, $info );
    }
    elsif ( $type =~ /int/ ) {
        _add_constraint_integer( $self, $col, $info );

        if ( $info->{extra}{unsigned} ) {
            _add_constraint_unsigned( $self, $col, $info );
        }

    }
    elsif ( $type =~ /enum|set/ && defined $info->{extra}{list} ) {
        _add_constraint_set( $self, $col, $info );
    }
}

sub _add_constraint_max_length {
    my ( $self, $col, $info ) = @_;

    $self->constraint( {
            type => 'MaxLength',
            name => $col,
            max  => $info->{size},
        } );
}

sub _add_constraint_integer {
    my ( $self, $col, $info ) = @_;

    $self->constraint( {
            type => 'Integer',
            name => $col,
        } );
}

sub _add_constraint_unsigned {
    my ( $self, $col, $info ) = @_;

    $self->constraint( {
            type => 'Range',
            name => $col,
            min  => 0,
        } );
}

sub _add_constraint_set {
    my ( $self, $col, $info ) = @_;

    $self->constraint( {
            type => 'Set',
            name => $col,
            set  => $info->{extra}{list},
        } );
}

sub parent {
    my $self = shift;

    if (@_) {
        $self->{parent} = shift;

        weaken( $self->{parent} );

        return $self;
    }

    return $self->{parent};
}

sub get_parent {
    my $self = shift;

    return $self->parent
        if !@_;

    my %args = _parse_args(@_);

    while ( defined ( my $parent = $self->parent ) ) {
        
        for my $name ( keys %args ) {
            my $value;

            if (   $parent->can($name)
                && defined( $value = $parent->$name )
                && $value eq $args{$name} )
            {
                return $parent;
            }
        }

        $self = $parent;
    }
    
    return;
}

sub _string_equals {
    my ( $a, $b ) = @_;

    return blessed($b) ? ( refaddr($a) eq refaddr($b) ) :
                         ( "$a" eq "$b" );
}

sub _object_equals {
    my ( $a, $b ) = @_;

    return blessed($b) ? ( refaddr($a) eq refaddr($b) ) :
                         undef;
}

1;
