package HTML::FormFu::ObjectUtil;

use strict;
use Exporter qw( import );

use HTML::FormFu::Util qw(
    _parse_args             require_class
    _get_elements           split_name
    _filter_components      _merge_hashes
);
use Config::Any;
use Data::Visitor::Callback;
use File::Spec;
use Scalar::Util qw( refaddr weaken blessed );
use List::MoreUtils qw( none uniq );
use Storable qw( dclone );
use Carp qw( croak );

our @form_and_block = qw(
    element
    deflator
    filter
    constraint
    inflator
    validator
    transformer
    plugin
    _single_element
    _single_deflator
    _single_filter
    _single_constraint
    _single_inflator
    _single_validator
    _single_transformer
    _require_constraint
    default_args
    element_defaults
    get_element
    get_elements
    get_deflators
    get_filters
    get_constraints
    get_inflators
    get_validators
    get_transformers
    get_plugins
    get_all_element
    get_all_elements
    get_field
    get_fields
    get_error
    get_errors
    clear_errors
    insert_before
    insert_after
    remove_element
);

our @form_and_element = qw(
    _require_deflator
    _require_filter
    _require_inflator
    _require_validator
    _require_transformer
    _require_plugin
    get_deflator
    get_filter
    get_constraint
    get_inflator
    get_validator
    get_transformer
    get_plugin
    model_config
);

our @EXPORT_OK = (
    @form_and_block,
    @form_and_element,
    qw(
        _coerce populate
        deflator
        load_config_file        load_config_filestem
        form
        insert_before           insert_after
        clone
        name
        stash
        constraints_from_dbic
        parent
        nested_name             nested_names
        get_nested_hash_value   set_nested_hash_value
        nested_hash_key_exists  delete_nested_hash_key
        remove_element
        ),
);

our %EXPORT_TAGS = (
    FORM_AND_BLOCK   => \@form_and_block,
    FORM_AND_ELEMENT => \@form_and_element,
);

sub default_args {
    my ( $self, $defaults ) = @_;

    $self->{default_args} ||= {};

    if ($defaults) {

        my @valid_types = qw(
            elements        deflators
            filters         constraints
            inflators       validators
            transformers    output_processors
        );

        for my $type ( keys %$defaults ) {
            croak "not a valid type for default_args: '$type'"
                if none { $type eq $_ } @valid_types;
        }

        $self->{default_args}
            = _merge_hashes( $self->{default_args}, $defaults );
    }

    return $self->{default_args};
}

sub element_defaults {
    my ( $self, $arg ) = @_;

    warn <<'WARNING';
element_defaults() method deprecated and is provided for compatability only: 
use default_args()->{elements} instead as this will be removed
WARNING

    $self->{default_args} ||= {};

    if ($arg) {
        if ( exists $self->{default_args}{elements} ) {
            $self->{default_args}{elements}
                = _merge_hashes( $self->{default_args}{elements}, $arg );
        }
        else {
            $self->{default_args}{elements} = $arg;
        }
    }

    return $self->{default_args}{elements};
}

sub _require_element {
    my ( $self, $arg ) = @_;

    $arg->{type} = 'Text' if !exists $arg->{type};

    my $type  = delete $arg->{type};
    my $class = $type;

    if ( not $class =~ s/^\+// ) {
        $class = "HTML::FormFu::Element::$class";
    }

    $type =~ s/^\+//;

    require_class($class);

    my $element = $class->new( {
            type   => $type,
            parent => $self,
        } );

    if ( $element->can('default_args') ) {
        $element->default_args( dclone $self->default_args );
    }

    # handle default_args
    if ( exists $self->default_args->{elements}{$type} ) {
        $arg = _merge_hashes( $self->default_args->{elements}{$type}, $arg, );
    }

    populate( $element, $arg );

    $element->setup;

    return $element;
}

sub get_elements {
    my $self = shift;
    my %args = _parse_args(@_);

    my @elements = @{ $self->_elements };

    return _get_elements( \%args, \@elements );
}

sub get_element {
    my $self = shift;

    my $e = $self->get_elements(@_);

    return @$e ? $e->[0] : ();
}

sub get_all_elements {
    my $self = shift;
    my %args = _parse_args(@_);

    my @e = map { $_, @{ $_->get_all_elements } } @{ $self->_elements };

    return _get_elements( \%args, \@e );
}

sub get_all_element {
    my $self = shift;

    my $e = $self->get_all_elements(@_);

    return @$e ? $e->[0] : ();
}

sub get_fields {
    my $self = shift;
    my %args = _parse_args(@_);

    my @e = map { $_->is_field && !$_->is_block ? $_ : @{ $_->get_fields } }
        @{ $self->_elements };

    return _get_elements( \%args, \@e );
}

sub get_field {
    my $self = shift;

    my $f = $self->get_fields(@_);

    return @$f ? $f->[0] : ();
}

sub _require_constraint {
    my ( $self, $type, $arg ) = @_;

    croak 'required arguments: $self, $type, \%options' if @_ != 3;

    eval { my %x = %$arg };
    croak "options argument must be hash-ref" if $@;

    my $abs = $type =~ s/^\+//;
    my $not = 0;

    if ( $type =~ /^Not_(\w+)$/i ) {
        $type = $1;
        $not  = 1;
    }

    my $class = $type;

    if ( !$abs ) {
        $class = "HTML::FormFu::Constraint::$class";
    }

    $type =~ s/^\+//;

    require_class($class);

    my $constraint = $class->new( {
            type   => $type,
            not    => $not,
            parent => $self,
        } );

    # handle default_args
    my $parent = $self->parent;

    if ( exists $parent->default_args->{constraints}{$type} ) {
        $arg = _merge_hashes( $parent->default_args->{constraints}{$type}, $arg,
        );
    }

    populate( $constraint, $arg );

    return $constraint;
}

sub get_errors {
    my $self = shift;
    my %args = _parse_args(@_);

    return [] if !$self->form->submitted;

    my @x = map { @{ $_->get_errors(@_) } } @{ $self->_elements };

    _filter_components( \%args, \@x );

    if ( !$args{forced} ) {
        @x = grep { !$_->forced } @x;
    }

    return \@x;
}

sub get_error {
    my $self = shift;

    return if !$self->form->submitted;

    my $c = $self->get_errors(@_);

    return @$c ? $c->[0] : ();
}

sub clear_errors {
    my ($self) = @_;

    map { $_->clear_errors } @{ $self->_elements };

    return;
}

sub populate {
    my ( $self, $arg_ref ) = @_;

    # shallow clone the args so we don't stomp on them
    my %args = %$arg_ref;

    # we have to handle element_defaults seperately, as it is no longer a
    # simple hash key

    if ( exists $args{element_defaults} ) {
        $self->element_defaults( delete $args{element_defaults} );
    }

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

sub insert_before {
    my ( $self, $object, $position ) = @_;

    # if $position is already a child of $object, remove it first

    for my $i ( 0 .. $#{ $self->_elements } ) {
        if ( refaddr( $self->_elements->[$i] ) eq refaddr($object) ) {
            splice @{ $self->_elements }, $i, 1;
            last;
        }
    }

    for my $i ( 0 .. $#{ $self->_elements } ) {
        if ( refaddr( $self->_elements->[$i] ) eq refaddr($position) ) {
            splice @{ $self->_elements }, $i, 0, $object;
            $object->{parent} = $position->{parent};
            weaken $object->{parent};
            return $object;
        }
    }

    croak 'position element not found';
}

sub insert_after {
    my ( $self, $object, $position ) = @_;

    # if $position is already a child of $object, remove it first

    for my $i ( 0 .. $#{ $self->_elements } ) {
        if ( refaddr( $self->_elements->[$i] ) eq refaddr($object) ) {
            splice @{ $self->_elements }, $i, 1;
            last;
        }
    }

    for my $i ( 0 .. $#{ $self->_elements } ) {
        if ( refaddr( $self->_elements->[$i] ) eq refaddr($position) ) {
            splice @{ $self->_elements }, $i + 1, 0, $object;
            $object->{parent} = $position->{parent};
            weaken $object->{parent};
            return $object;
        }
    }

    croak 'position element not found';
}

sub remove_element {
    my ( $self, $object ) = @_;

    for my $i ( 0 .. $#{ $self->_elements } ) {
        if ( refaddr( $self->_elements->[$i] ) eq refaddr($object) ) {
            splice @{ $self->_elements }, $i, 1;
            undef $object->{parent};
            return $object;
        }
    }

    croak 'element not found';
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

    # ImplicitUnicode ensures that values won't be double-encoded when we
    # encode() our output
    local $YAML::Syck::ImplicitUnicode = 1;

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
        $self->populate( dclone($config) );
    }

    return;
}

sub _coerce {
    my ( $self, %args ) = @_;

    for (qw( type attributes package )) {
        croak "$_ argument required" if !defined $args{$_};
    }

    my $class = $args{type};
    if ( $class !~ /^\+/ ) {
        $class = "HTML::FormFu::Element::$class";
    }

    require_class($class);

    my $element = $class->new( {
            name => $self->name,
            type => $args{type},
        } );

    for my $method ( qw(
        attributes              comment
        comment_attributes      label
        label_attributes        label_filename
        render_method           parent
        ) )
    {
        $element->$method( $self->$method );
    }

    _coerce_processors_and_errors( $self, $element, %args );

    $element->attributes( $args{attributes} );

    croak "element cannot be coerced to type '$args{type}'"
        if !$element->isa( $args{package} );

    $element->value( $self->value );

    return $element;
}

sub _coerce_processors_and_errors {
    my ( $self, $element, %args ) = @_;

    if ( $args{errors} && @{ $args{errors} } > 0 ) {

        my @errors = @{ $args{errors} };
        my @new_errors;

        for my $list ( qw(
            _filters        _constraints
            _inflators      _validators
            _transformers   _deflators
            ) )
        {
            $element->$list( [] );

            for my $processor ( @{ $self->$list } ) {
                my @errors_to_copy = map { $_->clone }
                    grep { $_->processor == $processor } @errors;

                my $processor_clone = $processor->clone;

                $processor_clone->parent($element);

                map { $_->processor($processor_clone) } @errors_to_copy;

                push @{ $element->$list }, $processor_clone;

                push @new_errors, @errors_to_copy;
            }
        }
        $element->_errors( \@new_errors );
    }
    else {
        $element->_errors( [] );
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
    $new{attributes}   = dclone $self->attributes;
    $new{tt_args}      = dclone $self->tt_args;
    $new{model_config} = dclone $self->model_config;

    $new{languages}
        = ref $self->languages
        ? dclone $self->languages
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

sub get_nested_hash_value {
    my ( $self, $param, $name ) = @_;

    my ( $root, @names ) = split_name($name);

    if ( !@names ) {
        return exists $param->{$root} ? $param->{$root} : undef;
    }

    my $ref = \$param->{$root};

    for (@names) {
        if (/^(0|[1-9][0-9]*)\z/) {
            croak "nested param clash for ARRAY $root"
                if ref $$ref ne 'ARRAY';

            return if $1 > $#{$$ref};

            $ref = \( $$ref->[$1] );
        }
        else {
            return if ref $$ref ne 'HASH' || !exists $$ref->{$_};

            $ref = \( $$ref->{$_} );
        }
    }

    return $$ref;
}

sub set_nested_hash_value {
    my ( $self, $param, $name, $value ) = @_;

    my ( $root, @names ) = split_name($name);

    if ( !@names ) {
        return $param->{$root} = $value;
    }

    my $ref = \$param->{$root};

    for (@names) {
        if (/^(0|[1-9][0-9]*)\z/) {
            $$ref = [] if !defined $$ref;

            croak "nested param clash for ARRAY $name"
                if ref $$ref ne 'ARRAY';

            $ref = \( $$ref->[$1] );
        }
        else {
            $$ref = {} if !defined $$ref;

            croak "nested param clash for HASH $name"
                if ref $$ref ne 'HASH';

            $ref = \( $$ref->{$_} );
        }
    }

    $$ref = $value;
}

sub delete_nested_hash_key {
    my ( $self, $param, $name ) = @_;

    my ( $root, @names ) = split_name($name);

    if ( !@names ) {
        delete $param->{$root};
        return;
    }

    my $ref = \$param->{$root};

    for my $i ( 0 .. $#names ) {
        my $name = $names[$i];

        if ( $name =~ /^(0|[1-9][0-9]*)\z/ ) {
            return if !defined $$ref;

            croak "nested param clash for ARRAY $name"
                if ref $$ref ne 'ARRAY';

            $ref = \( $$ref->[$1] );

            if ( $i == $#names ) {
                croak "can't delete hash key for an array";
            }
        }
        else {
            return if !defined $$ref;

            croak "nested param clash for HASH $name"
                if ref $$ref ne 'HASH';

            if ( $i == $#names ) {
                delete $$ref->{$name};
            }
            else {
                $ref = \( $$ref->{$name} );
            }
        }
    }

    return;
}

sub nested_hash_key_exists {
    my ( $self, $param, $name ) = @_;

    my ( $root, @names ) = split_name($name);

    if ( !@names ) {
        return exists $param->{$root};
    }

    my $ref = \$param->{$root};

    for my $i ( 0 .. $#names ) {
        my $part = $names[$i];

        if ( $part =~ /^(0|[1-9][0-9]*)\z/ ) {
            croak "nested param clash for ARRAY $root"
                if ref $$ref ne 'ARRAY';

            if ( $i == $#names ) {
                return $1 > $$ref->[$1] ? 1 : 0;
            }

            $ref = \( $$ref->[$1] );
        }
        else {
            if ( $i == $#names ) {
                return if !ref $$ref || ref($$ref) ne 'HASH';

                return exists $$ref->{$part} ? 1 : 0;
            }

            $ref = \( $$ref->{$part} );
        }
    }

    return;
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

sub element {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { $self->_single_element($_) } @$arg;
    }
    else {
        push @return, $self->_single_element($arg);
    }

    return @return == 1 ? $return[0] : @return;
}

sub deflator {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { $self->_single_deflator($_) } @$arg;
    }
    else {
        push @return, $self->_single_deflator($arg);
    }

    return @return == 1 ? $return[0] : @return;
}

sub filter {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { $self->_single_filter($_) } @$arg;
    }
    else {
        push @return, $self->_single_filter($arg);
    }

    return @return == 1 ? $return[0] : @return;
}

sub constraint {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { $self->_single_constraint($_) } @$arg;
    }
    else {
        push @return, $self->_single_constraint($arg);
    }

    return @return == 1 ? $return[0] : @return;
}

sub inflator {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { $self->_single_inflator($_) } @$arg;
    }
    else {
        push @return, $self->_single_inflator($arg);
    }

    return @return == 1 ? $return[0] : @return;
}

sub validator {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { $self->_single_validator($_) } @$arg;
    }
    else {
        push @return, $self->_single_validator($arg);
    }

    return @return == 1 ? $return[0] : @return;
}

sub transformer {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { $self->_single_transformer($_) } @$arg;
    }
    else {
        push @return, $self->_single_transformer($arg);
    }

    return @return == 1 ? $return[0] : @return;
}

sub plugin {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { $self->_single_plugin($_) } @$arg;
    }
    else {
        push @return, $self->_single_plugin($arg);
    }

    return @return == 1 ? $return[0] : @return;
}

sub _single_element {
    my ( $self, $arg ) = @_;

    if ( !ref $arg ) {
        $arg = { type => $arg };
    }
    elsif ( ref $arg eq 'HASH' ) {
        $arg = {%$arg};    # shallow clone
    }
    else {
        croak 'invalid args';
    }

    my $new = _require_element( $self, $arg );

    if (   $self->can('auto_fieldset')
        && $self->auto_fieldset
        && $new->type ne 'Fieldset' )
    {
        my ($target)
            = reverse @{ $self->get_elements( { type => 'Fieldset' } ) };

        push @{ $target->_elements }, $new;

        $new->{parent} = $target;
        weaken $new->{parent};
    }
    else {
        push @{ $self->_elements }, $new;
    }

    return $new;
}

sub _single_deflator {
    my ( $self, $arg ) = @_;

    if ( !ref $arg ) {
        $arg = { type => $arg };
    }
    elsif ( ref $arg eq 'HASH' ) {
        $arg = {%$arg};    # shallow clone
    }
    else {
        croak 'invalid args';
    }

    my @names = map { ref $_ ? @$_ : $_ }
        grep {defined} ( delete $arg->{name}, delete $arg->{names} );

    if ( !@names ) {
        @names = uniq
            grep {defined}
            map  { $_->nested_name } @{ $self->get_fields };
    }

    croak "no field names to add deflator to" if !@names;

    my $type = delete $arg->{type};

    my @return;

    for my $x (@names) {
        for my $field ( @{ $self->get_fields( { nested_name => $x } ) } ) {
            my $new = $field->_require_deflator( $type, $arg );
            push @{ $field->_deflators }, $new;
            push @return, $new;
        }
    }

    return @return;
}

sub _single_filter {
    my ( $self, $arg ) = @_;

    if ( !ref $arg ) {
        $arg = { type => $arg };
    }
    elsif ( ref $arg eq 'HASH' ) {
        $arg = {%$arg};    # shallow clone
    }
    else {
        croak 'invalid args';
    }

    my @names = map { ref $_ ? @$_ : $_ }
        grep {defined} ( delete $arg->{name}, delete $arg->{names} );

    if ( !@names ) {
        @names = uniq
            grep {defined}
            map  { $_->nested_name } @{ $self->get_fields };
    }

    croak "no field names to add filter to" if !@names;

    my $type = delete $arg->{type};

    my @return;

    for my $x (@names) {
        for my $field ( @{ $self->get_fields( { nested_name => $x } ) } ) {
            my $new = $field->_require_filter( $type, $arg );
            push @{ $field->_filters }, $new;
            push @return, $new;
        }
    }

    return @return;
}

sub _single_constraint {
    my ( $self, $arg ) = @_;

    if ( !ref $arg ) {
        $arg = { type => $arg };
    }
    elsif ( ref $arg eq 'HASH' ) {
        $arg = {%$arg};    # shallow clone
    }
    else {
        croak 'invalid args';
    }

    my @names = map { ref $_ ? @$_ : $_ }
        grep {defined} ( delete $arg->{name}, delete $arg->{names} );

    if ( !@names ) {
        @names = uniq
            grep {defined}
            map  { $_->nested_name } @{ $self->get_fields };
    }

    croak "no field names to add constraint to" if !@names;

    my $type = delete $arg->{type};

    my @return;

    for my $x (@names) {
        for my $field ( @{ $self->get_fields( { nested_name => $x } ) } ) {
            my $new = $field->_require_constraint( $type, $arg );
            push @{ $field->_constraints }, $new;
            push @return, $new;
        }
    }

    return @return;
}

sub _single_inflator {
    my ( $self, $arg ) = @_;

    if ( !ref $arg ) {
        $arg = { type => $arg };
    }
    elsif ( ref $arg eq 'HASH' ) {
        $arg = {%$arg};    # shallow clone
    }
    else {
        croak 'invalid args';
    }

    my @names = map { ref $_ ? @$_ : $_ }
        grep {defined} ( delete $arg->{name}, delete $arg->{names} );

    if ( !@names ) {
        @names = uniq
            grep {defined}
            map  { $_->nested_name } @{ $self->get_fields };
    }

    croak "no field names to add inflator to" if !@names;

    my $type = delete $arg->{type};

    my @return;

    for my $x (@names) {
        for my $field ( @{ $self->get_fields( { nested_name => $x } ) } ) {
            my $new = $field->_require_inflator( $type, $arg );
            push @{ $field->_inflators }, $new;
            push @return, $new;
        }
    }

    return @return;
}

sub _single_validator {
    my ( $self, $arg ) = @_;

    if ( !ref $arg ) {
        $arg = { type => $arg };
    }
    elsif ( ref $arg eq 'HASH' ) {
        $arg = {%$arg};    # shallow clone
    }
    else {
        croak 'invalid args';
    }

    my @names = map { ref $_ ? @$_ : $_ }
        grep {defined} ( delete $arg->{name}, delete $arg->{names} );

    if ( !@names ) {
        @names = uniq
            grep {defined}
            map  { $_->nested_name } @{ $self->get_fields };
    }

    croak "no field names to add validator to" if !@names;

    my $type = delete $arg->{type};

    my @return;

    for my $x (@names) {
        for my $field ( @{ $self->get_fields( { nested_name => $x } ) } ) {
            my $new = $field->_require_validator( $type, $arg );
            push @{ $field->_validators }, $new;
            push @return, $new;
        }
    }

    return @return;
}

sub _single_transformer {
    my ( $self, $arg ) = @_;

    if ( !ref $arg ) {
        $arg = { type => $arg };
    }
    elsif ( ref $arg eq 'HASH' ) {
        $arg = {%$arg};    # shallow clone
    }
    else {
        croak 'invalid args';
    }

    my @names = map { ref $_ ? @$_ : $_ }
        grep {defined} ( delete $arg->{name}, delete $arg->{names} );

    if ( !@names ) {
        @names = uniq
            grep {defined}
            map  { $_->nested_name } @{ $self->get_fields };
    }

    croak "no field names to add transformer to" if !@names;

    my $type = delete $arg->{type};

    my @return;

    for my $x (@names) {
        for my $field ( @{ $self->get_fields( { nested_name => $x } ) } ) {
            my $new = $field->_require_transformer( $type, $arg );
            push @{ $field->_transformers }, $new;
            push @return, $new;
        }
    }

    return @return;
}

sub get_deflators {
    my $self = shift;
    my %args = _parse_args(@_);

    my @x = map { @{ $_->get_deflators(@_) } } @{ $self->_elements };

    return _filter_components( \%args, \@x );
}

sub get_filters {
    my $self = shift;
    my %args = _parse_args(@_);

    my @x = map { @{ $_->get_filters(@_) } } @{ $self->_elements };

    return _filter_components( \%args, \@x );
}

sub get_constraints {
    my $self = shift;
    my %args = _parse_args(@_);

    my @x = map { @{ $_->get_constraints(@_) } } @{ $self->_elements };

    return _filter_components( \%args, \@x );
}

sub get_inflators {
    my $self = shift;
    my %args = _parse_args(@_);

    my @x = map { @{ $_->get_inflators(@_) } } @{ $self->_elements };

    return _filter_components( \%args, \@x );
}

sub get_validators {
    my $self = shift;
    my %args = _parse_args(@_);

    my @x = map { @{ $_->get_validators(@_) } } @{ $self->_elements };

    return _filter_components( \%args, \@x );
}

sub get_transformers {
    my $self = shift;
    my %args = _parse_args(@_);

    my @x = map { @{ $_->get_transformers(@_) } } @{ $self->_elements };

    return _filter_components( \%args, \@x );
}

sub get_plugins {
    my $self = shift;
    my %args = _parse_args(@_);

    return _filter_components( \%args, $self->_plugins );
}

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

1;
