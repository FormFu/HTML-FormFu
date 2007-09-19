package HTML::FormFu::ObjectUtil;

use strict;
use Exporter qw/ import /;

use HTML::FormFu::Util qw/ _parse_args require_class _get_elements /;
use Config::Any;
use Data::Visitor::Callback;
use Scalar::Util qw/ refaddr weaken blessed /;
use List::MoreUtils qw/ uniq /;
use Storable qw/ dclone /;
use Carp qw/ croak /;

our @form_and_block = qw/
    element
    deflator
    filter
    constraint
    inflator
    validator
    transformer
    _single_element
    _single_deflator
    _single_filter
    _single_constraint
    _single_inflator
    _single_validator
    _single_transformer
    _require_constraint
    get_element
    get_elements
    get_deflators
    get_filters
    get_constraints
    get_inflators
    get_validators
    get_transformers
    get_all_element
    get_all_elements
    get_field
    get_fields
    get_error
    get_errors
    clear_errors
    /;

our @form_and_element = qw/
    _require_deflator
    _require_filter
    _require_inflator
    _require_validator
    _require_transformer
    get_deflator
    get_filter
    get_constraint
    get_inflator
    get_validator
    get_transformer
    /;

our @EXPORT_OK = (qw/
    _render_class _coerce populate
    deflator 
    load_config_file form insert_before insert_after clone name stash
    constraints_from_dbic parent /,
    @form_and_block,
    @form_and_element );

our %EXPORT_TAGS = (
    FORM_AND_BLOCK => \@form_and_block,
    FORM_AND_ELEMENT => \@form_and_element,
);

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

    if ( $element->can('element_defaults') ) {
        $element->element_defaults( dclone $self->element_defaults );
    }

    if ( exists $self->element_defaults->{$type} ) {
        %$arg = ( %{ $self->element_defaults->{$type} }, %$arg );
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

    my @e
        = map { $_->is_field ? $_ : @{ $_->get_fields } } @{ $self->_elements };

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

    # inlined ObjectUtil::populate(), otherwise circular dependency
    eval {
        map { $constraint->$_( $arg->{$_} ) } keys %$arg;
    };
    croak $@ if $@;

    return $constraint;
}

sub get_errors {
    my $self = shift;
    my %args = _parse_args(@_);

    return [] if !$self->form->submitted;

    my @e = map { @{ $_->get_errors(@_) } } @{ $self->_elements };

    if ( exists $args{name} ) {
        @e = grep { $_->name eq $args{name} } @e;
    }

    if ( exists $args{type} ) {
        @e = grep { $_->type eq $args{type} } @e;
    }

    if ( exists $args{stage} ) {
        @e = grep { $_->stage eq $args{stage} } @e;
    }

    if ( !$args{forced} ) {
        @e = grep { !$_->forced } @e;
    }

    return \@e;
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
    my ( $self, $arg ) = @_;

    my @keys = qw(
        element_defaults auto_fieldset load_config_file element elements
        filter filters constraint constraints inflator inflators
        deflator deflators query validator validators transformer transformers
    );

    my %defer;
    for (@keys) {
        $defer{$_} = delete $arg->{$_} if exists $arg->{$_};
    }

    eval {
        map { $self->$_( $arg->{$_} ) } keys %$arg;

        map      { $self->$_( $defer{$_} ) }
            grep { exists $defer{$_} } @keys;
    };
    croak $@ if $@;

    return $self;
}

sub insert_before {
    my ( $self, $object, $position ) = @_;

    for my $i ( 1 .. @{ $self->_elements } ) {
        if ( refaddr( $self->_elements->[ $i - 1 ] ) eq refaddr($position) ) {
            splice @{ $self->_elements }, $i - 1, 0, $object;
            $object->{parent} = $position->{parent};
            weaken $object->{parent};
            return $object;
        }
    }

    croak 'position element not found';
}

sub insert_after {
    my ( $self, $object, $position ) = @_;

    for my $i ( 1 .. @{ $self->_elements } ) {
        if ( refaddr( $self->_elements->[ $i - 1 ] ) eq refaddr($position) ) {
            splice @{ $self->_elements }, $i, 0, $object;
            $object->{parent} = $position->{parent};
            weaken $object->{parent};
            return $object;
        }
    }

    croak 'position element not found';
}

sub load_config_file {
    my $self = shift;
    my @filenames;

    if ( @_ == 1 && ref $_[0] eq 'ARRAY' ) {
        push @filenames, @{ $_[0] };
    }
    else {
        push @filenames, @_;
    }

    for (@filenames) {
        croak "file not found: '$_'" if !-f $_;
    }

    # ignore $@, Config::Any will take care of loading YAML.pm if necessary.
    # ImplicitUnicode ensures that values won't be double-encoded when we
    # encode() our output
    eval { require YAML::Syck };
    local $YAML::Syck::ImplicitUnicode = 1;

    my $config_callback = $self->config_callback;
    my $data_visitor;

    if ( defined $config_callback ) {
        $data_visitor = Data::Visitor::Callback->new( %$config_callback,
            ignore_return_values => 1, );
    }

    for my $file (@filenames) {

        my $config = Config::Any->load_files( {
                files   => [$file],
                use_ext => 1,
            } );

        my $data = $config->[0]->{$file};

        if ( defined $data_visitor ) {
            $data_visitor->visit($data);
        }

        $self->populate($data);
    }

    return $self;
}

sub _render_class {
    my ( $self, $dir ) = @_;
    my $class;

    if ( defined $self->render_class ) {
        $class = $self->render_class;
    }
    elsif ( defined $dir && defined $self->render_class_suffix ) {
        $class
            = $self->render_class_prefix . "::" 
            . $dir . "::"
            . $self->render_class_suffix;
    }
    elsif ( defined $dir ) {
        $class = $self->render_class_prefix . "::" . $dir;
    }
    else {
        $class = $self->render_class_prefix . "::" . $self->render_class_suffix;
    }

    return $class;
}

# create a map of errors to processors, so we can reassociate the new cloned
# errors with the new cloned processors

# clone the errors
#    my @errors = map { $_->clone } @{ $self->_errors };

# reassociate the errors with the processors
#    map { $_->processor() } @errors;

sub _coerce {
    my ( $self, %args ) = @_;

    for (qw/ type attributes package /) {
        croak "$_ argument required" if !defined $args{$_};
    }

    croak "type argument required" if !defined $args{type};

    my $class = $args{type};
    if ( $class !~ /^\+/ ) {
        $class = "HTML::FormFu::Element::$class";
    }

    require_class($class);

    my $element = $class->new( {
            name => $self->name,
            type => $args{type},
        } );

    for my $method (
        qw/ attributes comment comment_attributes label label_attributes
        label_filename render_method parent /
        )
    {
        $element->$method( $self->$method );
    }

    _coerce_processors_and_errors( $self, $element, %args );

    $element->attributes( $args{attributes} );

    croak "element cannot be coerced to type '$args{type}'"
        if !$element->isa( $args{package} );

    my $render = $element->render;

    $render->{value} = $self->value;

    # because $element goes out of scope at the end of this subroutine,
    # we need an unweakened reference, so bypass parent() method
    $render->{parent} = $element;

    return $render;
}

sub _coerce_processors_and_errors {
    my ( $self, $element, %args ) = @_;

    if ( $args{errors} && @{ $args{errors} } > 0 ) {

        my @errors = @{ $args{errors} };
        my @new_errors;

        for my $list (
            qw/ _filters _constraints _inflators _validators
            _transformers _deflators /
            )
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

    while ( defined $self->parent ) {
        $self = $self->parent;
    }

    return $self;
}

sub clone {
    my ($self) = @_;

    my %new = %$self;

    $new{_elements}         = [ map { $_->clone } @{ $self->_elements } ];
    $new{attributes}        = dclone $self->attributes;
    $new{render_class_args} = dclone $self->render_class_args;
    $new{element_defaults}  = dclone $self->element_defaults;
    $new{languages}         = dclone $self->languages;

    return bless \%new, ref $self;
}

sub name {
    my $self = shift;

    croak 'cannot use name() as a setter' if @_;

    return $self->parent->name;
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
};

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
};

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
};

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
};

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
};

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
};

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
};

sub _single_element {
    my ( $self, $arg ) = @_;

    if ( !ref $arg ) {
        $arg = { type => $arg };
    }
    elsif ( ref $arg ne 'HASH' ) {
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
    elsif ( ref $arg ne 'HASH' ) {
        croak 'invalid args';
    }

    my @names = map { ref $_ ? @$_ : $_ }
        grep {defined}
        ( delete $arg->{name}, delete $arg->{names} );

    @names = uniq( map { $_->name }
        grep { defined $_->name } @{ $self->get_fields } )
        if !@names;

    croak "no field names to add deflator to" if !@names;

    my $type = delete $arg->{type};

    my @return;
    
    for my $x (@names) {
        for my $field ( @{ $self->get_fields( { name => $x } ) } ) {
            my $new = $field->_require_deflator( $type, $arg );
            push @{ $field->_deflators }, $new;
            push @return, $new;
        }
    }
    
    return @return;
};

sub _single_filter {
    my ( $self, $arg ) = @_;

    if ( !ref $arg ) {
        $arg = { type => $arg };
    }
    elsif ( ref $arg ne 'HASH' ) {
        croak 'invalid args';
    }

    my @names = map { ref $_ ? @$_ : $_ }
        grep {defined}
        ( delete $arg->{name}, delete $arg->{names} );

    @names = uniq( map { $_->name }
        grep { defined $_->name } @{ $self->get_fields } )
        if !@names;

    croak "no field names to add filter to" if !@names;

    my $type = delete $arg->{type};

    my @return;
    
    for my $x (@names) {
        for my $field ( @{ $self->get_fields( { name => $x } ) } ) {
            my $new = $field->_require_filter( $type, $arg );
            push @{ $field->_filters }, $new;
            push @return, $new;
        }
    }
    
    return @return;
};

sub _single_constraint {
    my ( $self, $arg ) = @_;

    if ( !ref $arg ) {
        $arg = { type => $arg };
    }
    elsif ( ref $arg ne 'HASH' ) {
        croak 'invalid args';
    }

    my @names = map { ref $_ ? @$_ : $_ }
        grep {defined}
        ( delete $arg->{name}, delete $arg->{names} );

    @names = uniq( map { $_->name }
        grep { defined $_->name } @{ $self->get_fields } )
        if !@names;

    croak "no field names to add constraint to" if !@names;

    my $type = delete $arg->{type};

    my @return;
    
    for my $x (@names) {
        for my $field ( @{ $self->get_fields( { name => $x } ) } ) {
            my $new = $field->_require_constraint( $type, $arg );
            push @{ $field->_constraints }, $new;
            push @return, $new;
        }
    }
    
    return @return;
};

sub _single_inflator {
    my ( $self, $arg ) = @_;

    if ( !ref $arg ) {
        $arg = { type => $arg };
    }
    elsif ( ref $arg ne 'HASH' ) {
        croak 'invalid args';
    }

    my @names = map { ref $_ ? @$_ : $_ }
        grep {defined}
        ( delete $arg->{name}, delete $arg->{names} );

    @names = uniq( map { $_->name }
        grep { defined $_->name } @{ $self->get_fields } )
        if !@names;

    croak "no field names to add inflator to" if !@names;

    my $type = delete $arg->{type};

    my @return;
    
    for my $x (@names) {
        for my $field ( @{ $self->get_fields( { name => $x } ) } ) {
            my $new = $field->_require_inflator( $type, $arg );
            push @{ $field->_inflators }, $new;
            push @return, $new;
        }
    }
    
    return @return;
};

sub _single_validator {
    my ( $self, $arg ) = @_;

    if ( !ref $arg ) {
        $arg = { type => $arg };
    }
    elsif ( ref $arg ne 'HASH' ) {
        croak 'invalid args';
    }

    my @names = map { ref $_ ? @$_ : $_ }
        grep {defined}
        ( delete $arg->{name}, delete $arg->{names} );

    @names = uniq( map { $_->name }
        grep { defined $_->name } @{ $self->get_fields } )
        if !@names;

    croak "no field names to add validator to" if !@names;

    my $type = delete $arg->{type};

    my @return;
    
    for my $x (@names) {
        for my $field ( @{ $self->get_fields( { name => $x } ) } ) {
            my $new = $field->_require_validator( $type, $arg );
            push @{ $field->_validators }, $new;
            push @return, $new;
        }
    }
    
    return @return;
};

sub _single_transformer {
    my ( $self, $arg ) = @_;

    if ( !ref $arg ) {
        $arg = { type => $arg };
    }
    elsif ( ref $arg ne 'HASH' ) {
        croak 'invalid args';
    }

    my @names = map { ref $_ ? @$_ : $_ }
        grep {defined}
        ( delete $arg->{name}, delete $arg->{names} );

    @names = uniq( map { $_->name }
        grep { defined $_->name } @{ $self->get_fields } )
        if !@names;

    croak "no field names to add transformer to" if !@names;

    my $type = delete $arg->{type};

    my @return;
    
    for my $x (@names) {
        for my $field ( @{ $self->get_fields( { name => $x } ) } ) {
            my $new = $field->_require_transformer( $type, $arg );
            push @{ $field->_transformers }, $new;
            push @return, $new;
        }
    }
    
    return @return;
};

sub get_deflators {
    my $self = shift;
    my %args = _parse_args(@_);

    my @x = map { @{ $_->get_deflators(@_) } } @{ $self->_elements };

    if ( exists $args{name} ) {
        @x = grep { $_->name eq $args{name} } @x;
    }

    if ( exists $args{type} ) {
        @x = grep { $_->type eq $args{type} } @x;
    }

    return \@x;
};

sub get_filters {
    my $self = shift;
    my %args = _parse_args(@_);

    my @x = map { @{ $_->get_filters(@_) } } @{ $self->_elements };

    if ( exists $args{name} ) {
        @x = grep { $_->name eq $args{name} } @x;
    }

    if ( exists $args{type} ) {
        @x = grep { $_->type eq $args{type} } @x;
    }

    return \@x;
};

sub get_constraints {
    my $self = shift;
    my %args = _parse_args(@_);

    my @x = map { @{ $_->get_constraints(@_) } } @{ $self->_elements };

    if ( exists $args{name} ) {
        @x = grep { $_->name eq $args{name} } @x;
    }

    if ( exists $args{type} ) {
        @x = grep { $_->type eq $args{type} } @x;
    }

    return \@x;
};

sub get_inflators {
    my $self = shift;
    my %args = _parse_args(@_);

    my @x = map { @{ $_->get_inflators(@_) } } @{ $self->_elements };

    if ( exists $args{name} ) {
        @x = grep { $_->name eq $args{name} } @x;
    }

    if ( exists $args{type} ) {
        @x = grep { $_->type eq $args{type} } @x;
    }

    return \@x;
};

sub get_validators {
    my $self = shift;
    my %args = _parse_args(@_);

    my @x = map { @{ $_->get_validators(@_) } } @{ $self->_elements };

    if ( exists $args{name} ) {
        @x = grep { $_->name eq $args{name} } @x;
    }

    if ( exists $args{type} ) {
        @x = grep { $_->type eq $args{type} } @x;
    }

    return \@x;
};

sub get_transformers {
    my $self = shift;
    my %args = _parse_args(@_);

    my @x = map { @{ $_->get_transformers(@_) } } @{ $self->_elements };

    if ( exists $args{name} ) {
        @x = grep { $_->name eq $args{name} } @x;
    }

    if ( exists $args{type} ) {
        @x = grep { $_->type eq $args{type} } @x;
    }

    return \@x;
};

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

    $object->populate( $opt );

    return $object;
};

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

    $object->populate( $opt );

    return $object;
};

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

    $object->populate( $opt );

    return $object;
};

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

    $object->populate( $opt );

    return $object;
};

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

    $object->populate( $opt );

    return $object;
};

sub get_deflator {
    my $self = shift;

    my $x = $self->get_deflators(@_);

    return @$x ? $x->[0] : ();
};

sub get_filter {
    my $self = shift;

    my $x = $self->get_filters(@_);

    return @$x ? $x->[0] : ();
};

sub get_constraint {
    my $self = shift;

    my $x = $self->get_constraints(@_);

    return @$x ? $x->[0] : ();
};

sub get_inflator {
    my $self = shift;

    my $x = $self->get_inflators(@_);

    return @$x ? $x->[0] : ();
};

sub get_validator {
    my $self = shift;

    my $x = $self->get_validators(@_);

    return @$x ? $x->[0] : ();
};

sub get_transformer {
    my $self = shift;

    my $x = $self->get_transformers(@_);

    return @$x ? $x->[0] : ();
};

1;
