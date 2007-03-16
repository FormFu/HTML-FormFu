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

our @EXPORT_OK = qw/ element constraint filter inflator validator 
    _render_class _coerce populate
    _require_constraint _require_filter _require_inflator _require_deflator
    _require_validator
    deflator get_fields get_field get_constraints
    get_constraint get_filters get_filter get_elements get_element
    get_deflators get_deflator get_inflators get_inflator get_all_elements
    get_validators get_validator get_errors get_error delete_errors
    load_config_file form insert_after clone name stash /;

# build methods

for my $method (qw/ element deflator filter constraint inflator validator /) {
    no strict 'refs';
    
    my $sub = sub {
        my ( $self, $arg ) = @_;
        my @return;
        my $sub_name = "_single_$method";
    
        if ( ref $arg eq 'ARRAY' ) {
            push @return, map { &$sub_name( $self, $_ ) } @$arg;
        }
        else {
            push @return, &$sub_name( $self, $arg );
        }
    
        return @return == 1 ? $return[0] : @return;
        };
    
    my $name = __PACKAGE__ . "::$method";
    
    *{$name} = $sub;
}

# build _single_X methods

for my $method (qw/ deflator constraint filter inflator validator /) {
    no strict 'refs';
    
    my $sub = sub {
        my ( $self, $arg ) = @_;
        my @items;
    
        if ( ref $arg eq 'HASH' ) {
            push @items, $arg;
        }
        elsif ( !ref $arg ) {
            push @items, { type => $arg };
        }
        else {
            croak 'invalid args';
        }
    
        my @return;
    
        for my $item (@items) {
            my @names = 
                map { ref $_ ? @$_ : $_}
                grep { defined }
                ( delete $item->{name}, delete $item->{names} );
    
            @names = uniq map { $_->name } grep { defined $_->name } 
                @{ $self->get_fields }
                if !@names;
    
            croak "no field names to add $method to" if !@names;
            
            my $type = delete $item->{type};
    
            for my $name (@names) {
                my $require_sub = "_require_$method";
                my $array_method = "_${method}s";
                
                for my $field ( @{ $self->get_fields( { name => $name } ) } ) {
                    my $new = &$require_sub( $field, $type, $item );
                    push @{ $field->$array_method }, $new;
                    push @return, $new;
                }
            }
        }
    
        return @return;
        };
    
    my $name = __PACKAGE__ . "::_single_$method";
    
    *{$name} = $sub;
}

# build _require_X methods

for my $method (qw/ deflator filter inflator validator /) {
    no strict 'refs';
    
    my $sub = sub {
        my ( $self, $type, $opt ) = @_;
    
        croak 'required arguments: $self, $type, \%options' if @_ != 3;
    
        eval { my %x = %$opt };
        croak "options argument must be hash-ref" if $@;
    
        my $class = $type;
        if ( not $class =~ s/^\+// ) {
            $class = "HTML::FormFu::" . ucfirst($method) . "::$class";
        }
        
        $type =~ s/^\+//;
        
        require_class($class);
    
        my $object = $class->new( {
                "${method}_type" => $type,
                parent           => $self,
            } );
    
        weaken( $object->{parent} );
    
        # inlined ObjectUtil::populate(), otherwise circular dependency
        eval {
            map { $object->$_( $opt->{$_} ) } keys %$opt;
        };
        croak $@ if $@;
    
        return $object;
        };
    
    my $name = __PACKAGE__ . "::_require_$method";
    
    *{$name} = $sub;
}

# build get_Xs methods

for my $method (qw/ deflator filter constraint inflator validator /) {
    no strict 'refs';
    
    my $sub = sub {
        my $self = shift;
        my %args = _parse_args(@_);
        my $get_method = "get_${method}s";
        
        my @x = map { @{ $_->$get_method(@_) } } @{ $self->_elements };
        
        if ( exists $args{name} ) {
            @x = grep { $_->name eq $args{name} } @x;
        }
        
        if ( exists $args{type} ) {
            my $type_method = "${method}_type";
            
            @x = grep { $_->$type_method eq $args{type} } @x;
        }
        
        return \@x;
        };
    
    my $name = __PACKAGE__ . "::get_${method}s";
    
    *{$name} = $sub;
}

# build get_X methods

for my $method (qw/ deflator filter constraint inflator validator /) {
    no strict 'refs';
    
    my $sub = sub {
        my $self = shift;
        my $get_method = "get_${method}s";
        
        my $x = $self->$get_method(@_);
    
        return @$x ? $x->[0] : ();
        };
    
    my $name = __PACKAGE__ . "::get_$method";
    
    *{$name} = $sub;
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
    
    $type =~ s/^\+//;

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

sub get_errors {
    my $self = shift;
    my %args = _parse_args(@_);

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
    
    return \@e;
}

sub get_error {
    my $self = shift;

    my $c = $self->get_errors(@_);

    return @$c ? $c->[0] : ();
}

sub delete_errors {
    my ($self) = @_;
    
    map { $_->delete_errors } @{ $self->_elements };
    
    return;
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
