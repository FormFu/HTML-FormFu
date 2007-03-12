package HTML::FormFu::ObjectUtil;

use strict;
use warnings;
use Exporter qw/ import /;

use HTML::FormFu::Util qw/ _parse_args require_class _get_elements /;
use Config::Any;
use List::MoreUtils qw/ uniq /;
use Scalar::Util qw/ refaddr weaken /;
use Storable qw/ dclone /;
use Carp qw/ croak /;

our @EXPORT_OK = qw/ element constraint filter inflator load_config_file
    _render_class _coerce populate
    _require_constraint _require_filter _require_inflator _require_deflator
    deflator get_fields get_field get_constraints
    get_constraint get_filters get_filter get_elements get_element
    get_deflators get_deflator get_inflators get_inflator get_all_elements
    form insert_after clone name stash /;

sub element {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { _single_element( $self, $_ ) } @$arg;
    }
    else {
        push @return, _single_element( $self, $arg );
    }

    return @return == 1 ? $return[0] : @return;
}

sub _single_element {
    my ( $self, $element ) = @_;
    my @elements;
    
    if ( ref $element eq 'HASH' ) {
        push @elements, $element;
    }
    elsif ( !ref $element ) {
        push @elements, { type => $element };
    }
    else {
        croak 'invalid args';
    }

    my @return;

    for (@elements) {
        my $e = _require_element( $self, $_ );
        push @return, $e;
        
        if ( $self->can('auto_fieldset') 
             && $self->auto_fieldset 
             && $e->element_type ne 'fieldset' )
        {
            my ($target) = reverse @{ $self->get_elements({ type => 'fieldset' }) };
            
            push @{ $target->_elements }, $e;
        }
        else {
            push @{ $self->_elements }, $e;
        }
    }
    
    return @return;
}

sub _require_element {
    my ( $self, $arg ) = @_;

    $arg->{type} = 'text' if !exists $arg->{type};

    my $type = delete $arg->{type};
    my $class = $type;
    if ( $class !~ /^\+/ ) {
        $class = "HTML::FormFu::Element::$class";
    }

    require_class($class);

    my $element = $class->new( {
            element_type    => $type,
            parent          => $self,
        } );

    weaken( $element->{parent} );

    if ( $element->can('element_defaults') ) {
        $element->element_defaults( dclone $self->element_defaults );
    }

    if ( exists $self->element_defaults->{ $type } ) {
        %$arg = ( %{ $self->element_defaults->{$type} }, %$arg );
    }

    for (qw/ render_class_prefix render_method /)
    {
        $arg->{$_} = $self->$_ if !exists $arg->{$_};
    }

    $arg->{render_class_args} = dclone $self->render_class_args
        if !exists $arg->{render_class_args};

    populate( $element, $arg );

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

sub get_fields {
    my $self = shift;
    my %args = _parse_args(@_);

    my @e = map { $_->is_field ? $_ : @{ $_->get_fields } } @{ $self->_elements };

    return _get_elements( \%args, \@e );
}

sub get_field {
    my $self = shift;

    my $f = $self->get_fields(@_);

    return @$f ? $f->[0] : ();
}

sub constraint {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { _single_constraint( $self, $_ ) } @$arg;
    }
    else {
        push @return, _single_constraint( $self, $arg );
    }

    return @return == 1 ? $return[0] : @return;
}

sub _single_constraint {
    my ( $self, $constraint ) = @_;
    my @constraints;

    if ( ref $constraint eq 'HASH' ) {
        push @constraints, $constraint;
    }
    elsif ( !ref $constraint ) {
        push @constraints, { type => $constraint };
    }
    else {
        croak 'invalid args';
    }

    my @return;

    for my $c (@constraints) {
        my @names = 
            map { ref $_ ? @$_ : $_}
            grep { defined }
            ( delete $c->{name}, delete $c->{names} );

        @names = uniq map { $_->name } grep { defined $_->name } 
            @{ $self->get_fields }
            if !@names;

        croak 'no field names to add constraint to' if !@names;
        
        my $type = delete $c->{type};

        for my $name (@names) {
            for my $field ( @{ $self->get_fields( { name => $name } ) } ) {
                my $cons = _require_constraint( $field, $type, $c );
                push @{ $field->_constraints }, $cons;
                push @return, $cons;
            }
        }
    }

    return @return;
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

    require_class($class);

    my $constraint = $class->new( {
            constraint_type => $type,
            not             => $not,
            parent          => $self,
        } );

    weaken( $constraint->{parent} );

    # inlined ObjectUtil::populate(), otherwise circular dependency
    eval {
        map { $constraint->$_( $arg->{$_} ) } keys %$arg;
    };
    croak $@ if $@;

    return $constraint;
}

sub get_constraints {
    my $self = shift;
    my %args = _parse_args(@_);

    my @c = map { @{ $_->get_constraints(@_) } } @{ $self->_elements };
    
    if ( exists $args{type} ) {
        @c = grep { $_->constraint_type eq $args{type} } @c;
    }
    
    return \@c;
}

sub get_constraint {
    my $self = shift;

    my $c = $self->get_constraints(@_);

    return @$c ? $c->[0] : ();
}

sub get_filters {
    my $self = shift;
    my %args = _parse_args(@_);

    my @f = map { @{ $_->get_filters(@_) } } @{ $self->_elements };
    
    if ( exists $args{type} ) {
        @f = grep { $_->filter_type eq $args{type} } @f;
    }
    
    return \@f;
}

sub get_filter {
    my $self = shift;

    my $f = $self->get_filters(@_);

    return @$f ? $f->[0] : ();
}

sub get_deflators {
    my $self = shift;
    my %args = _parse_args(@_);

    my @d = map { @{ $_->get_deflators(@_) } } @{ $self->_elements };
    
    if ( exists $args{type} ) {
        @d = grep { $_->deflator_type eq $args{type} } @d;
    }
    
    return \@d;
}

sub get_deflator {
    my $self = shift;

    my $d = $self->get_deflators(@_);

    return @$d ? $d->[0] : ();
}

sub get_inflators {
    my $self = shift;
    my %args = _parse_args(@_);

    my @i = map { @{ $_->get_inflators(@_) } } @{ $self->_elements };
    
    if ( exists $args{type} ) {
        @i = grep { $_->inflator_type eq $args{type} } @i;
    }
    
    return \@i;
}

sub get_inflator {
    my $self = shift;

    my $i = $self->get_inflators(@_);

    return @$i ? $i->[0] : ();
}

sub populate {
    my ( $self, $arg ) = @_;

    my @keys = qw(
        element_defaults auto_fieldset load_config_file element elements 
        filter filters constraint constraints inflator inflators 
        deflator deflators query
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

sub filter {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { _single_filter( $self, $_ ) } @$arg;
    }
    else {
        push @return, _single_filter( $self, $arg );
    }

    return @return == 1 ? $return[0] : @return;
}

sub _single_filter {
    my ( $self, $filter ) = @_;
    my @filters;

    if ( ref $filter eq 'HASH' ) {
        push @filters, $filter;
    }
    elsif ( !ref $filter ) {
        push @filters, { type => $filter };
    }
    else {
        croak 'invalid args';
    }

    my @return;

    for my $f (@filters) {
        my @names = 
            map { ref $_ ? @$_ : $_}
            grep { defined }
            ( delete $f->{name}, delete $f->{names} );

        @names = uniq map { $_->name } grep { defined $_->name } 
            @{ $self->get_fields }
            if !@names;

        croak 'no field names to add filter to' if !@names;
        
        my $type = delete $f->{type};

        for my $name (@names) {
            for my $field ( @{ $self->get_fields( { name => $name } ) } ) {
                my $new = _require_filter( $field, $type, $f );
                push @{ $field->_filters }, $new;
                push @return, $new;
            }
        }
    }

    return @return;
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

    require_class($class);

    my $filter = $class->new( {
            filter_type => $type,
            parent      => $self,
        } );

    weaken( $filter->{parent} );

    # inlined ObjectUtil::populate(), otherwise circular dependency
    eval {
        map { $filter->$_( $opt->{$_} ) } keys %$opt;
    };
    croak $@ if $@;

    return $filter;
}

sub deflator {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { _single_deflator( $self, $_ ) } @$arg;
    }
    else {
        push @return, _single_deflator( $self, $arg );
    }

    return @return == 1 ? $return[0] : @return;
}

sub _single_deflator {
    my ( $self, $deflator ) = @_;
    my @deflators;

    if ( ref $deflator eq 'HASH' ) {
        push @deflators, $deflator;
    }
    elsif ( !ref $deflator ) {
        push @deflators, { type => $deflator };
    }
    else {
        croak 'invalid args';
    }

    my @return;

    for my $d (@deflators) {
        my @names = 
            map { ref $_ ? @$_ : $_}
            grep { defined }
            ( delete $d->{name}, delete $d->{names} );

        @names = uniq map { $_->name } grep { defined $_->name } 
            @{ $self->get_fields }
            if !@names;

        croak 'no field names to add deflator to' if !@names;
        
        my $type = delete $d->{type};

        for my $name (@names) {
            for my $field ( @{ $self->get_fields( { name => $name } ) } ) {
                my $new = _require_deflator( $field, $type, $d );
                push @{ $field->_deflators }, $new;
                push @return, $new;
            }
        }
    }

    return @return;
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

    require_class($class);

    my $deflator = $class->new( {
            deflator_type => $type,
            parent        => $self,
        } );

    weaken( $deflator->{parent} );

    # inlined ObjectUtil::populate(), otherwise circular dependency
    eval {
        map { $deflator->$_( $opt->{$_} ) } keys %$opt;
    };
    croak $@ if $@;

    return $deflator;
}

sub inflator {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { _single_inflator( $self, $_ ) } @$arg;
    }
    else {
        push @return, _single_inflator( $self, $arg );
    }

    return @return == 1 ? $return[0] : @return;
}

sub _single_inflator {
    my ( $self, $inflator ) = @_;
    my @inflators;

    if ( ref $inflator eq 'HASH' ) {
        push @inflators, $inflator;
    }
    elsif ( !ref $inflator ) {
        push @inflators, { type => $inflator };
    }
    else {
        croak 'invalid args';
    }

    my @return;

    for my $i (@inflators) {
        my @names = 
            map { ref $_ ? @$_ : $_}
            grep { defined }
            ( delete $i->{name}, delete $i->{names} );

        @names = uniq map { $_->name } grep { defined $_->name } 
            @{ $self->get_fields }
            if !@names;

        croak 'no field names to add inflator to' if !@names;
        
        my $type = delete $i->{type};

        for my $name (@names) {
            for my $field ( @{ $self->get_fields( { name => $name } ) } ) {
                my $new = _require_inflator( $field, $type, $i );
                push @{ $field->_inflators }, $new;
                push @return, $new;
            }
        }
    }

    return @return;
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

    require_class($class);

    my $inflator = $class->new( {
            inflator_type => $type,
            parent        => $self,
        } );

    weaken( $inflator->{parent} );

    # inlined ObjectUtil::populate(), otherwise circular dependency
    eval {
        map { $inflator->$_( $opt->{$_} ) } keys %$opt;
    };
    croak $@ if $@;

    return $inflator;
}

sub insert_after {
    my ( $self, $object, $position ) = @_;
    
    for my $i ( 1 .. @{ $self->_elements } ) {
        if ( refaddr( $self->_elements->[$i-1] ) eq refaddr($position) ) {
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

    my $files = Config::Any->load_files( {
            files   => \@filenames,
            use_ext => 1,
        } );

    my %config;
    for my $file (@$files) {
        %config = ( %config, %{ $file->{ ( keys %$file )[0] } } );
    }

    $self->populate( \%config );

    return $self;
}

sub _render_class {
    my ( $self, $dir ) = @_;

    if ( defined $self->{render_class} ) {
        return $self->{render_class};
    }
    elsif ( defined $dir ) {
        return $self->{render_class_prefix} . "::" . $dir . "::"
            . $self->{render_class_suffix};
    }
    else {
        return $self->{render_class_prefix} . "::"
            . $self->{render_class_suffix};
    }
}

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
            name         => $self->name,
            element_type => $args{type},
            errors       => $args{errors},
        } );

    for my $method (
        qw/ attributes render_class_prefix
        render_class_args comment comment_attributes label label_attributes
        label_filename render_method parent /
        )
    {
        $element->$method( $self->$method );
    }

    $element->attributes( $args{attributes} );

    croak "element cannot be coerced to type '$args{type}'"
        if !$element->isa( $args{package} );

    my $render = $element->render;

    $render->{value} = $self->value;

    return $render;
}

sub form {
    my ($self) = @_;
    
    while ( defined $self->parent ) {
        $self = $self->parent;
    }
    
    return $self;
}

sub clone {
    my ( $self ) = @_;
    
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
};

1;
