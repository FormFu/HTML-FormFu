use strict;

package HTML::FormFu::Role::FormAndBlockMethods;

use Moose::Role;

use HTML::FormFu::Util qw( _merge_hashes );
use Carp qw( croak );
use List::Util 1.33 qw( none );

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

sub constraints_from_dbic {
    my ( $self, $source, $map ) = @_;

    if ( 2 == @_ && 'ARRAY' eq ref $source ) {
        ( $source, $map ) = @$source;
    }

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

    # We need to ensure we're only using this Block's children,
    # as far as 'nested_name' is concerned.
    # But we can't use get_elements() in case the fields are in sub-Blocks
    # that don't have 'nested_name' set.

    my $parent = $self;
    my @parent_names;

    do {
        my $nested_name = $parent->nested_name;
        if ( defined $nested_name && length $nested_name ) {
            push @parent_names, $nested_name;
        }
    } while ( $parent = $parent->parent );

    my $fields = $self->get_fields($col);
    return if !@$fields;

    if (@parent_names) {
        my $pre = join ".", reverse @parent_names;
        @$fields = grep { $_->nested_name eq "$pre." . $_->name } @$fields;
    }
    else {
        @$fields = grep { $_->nested_name eq $_->name } @$fields;
    }

    return if !@$fields;

    return if !defined $info->{data_type};

    my $type = lc $info->{data_type};

    if ( $type =~ /(char|text|binary)\z/ && defined $info->{size} ) {

        # char, varchar, *text, binary, varbinary
        _add_constraint_max_length( $self, $fields, $info );
    }
    elsif ( $type =~ /int/ ) {
        _add_constraint_integer( $self, $fields, $info );

        if ( $info->{extra}{unsigned} ) {
            _add_constraint_unsigned( $self, $fields, $info );
        }
    }
    elsif ( $type =~ /enum|set/ && defined $info->{extra}{list} ) {
        _add_constraint_set( $self, $fields, $info );
    }
    elsif ( $type =~ /bool/ ) {
        _add_constraint_bool( $self, $fields, $info );
    }
    elsif ( $type =~ /decimal/ ) {
        _add_constraint_decimal( $self, $fields, $info );
    }
}

sub _add_constraint_max_length {
    my ( $self, $fields, $info ) = @_;

    map { $_->constraint( { type => 'MaxLength', max => $info->{size}, } ) }
        @$fields;
}

sub _add_constraint_integer {
    my ( $self, $fields, $info ) = @_;

    map { $_->constraint( { type => 'Integer', } ) } @$fields;
}

sub _add_constraint_unsigned {
    my ( $self, $fields, $info ) = @_;

    map { $_->constraint( { type => 'Range', min => 0, } ) } @$fields;
}

sub _add_constraint_set {
    my ( $self, $fields, $info ) = @_;

    map { $_->constraint( { type => 'Set', set => $info->{extra}{list}, } ) }
        @$fields;
}

sub _add_constraint_bool {
    my ( $self, $fields, $info ) = @_;

    map { $_->constraint( { type => 'Set', set => [ 0, 1 ] } ) } @$fields;
}

sub _add_constraint_decimal {
    my ( $self, $fields, $info ) = @_;

    my $size = $info->{size};
    my $regex;

    if ( defined $size ) {
        if ( 'ARRAY' eq ref $size && 2 == @$size ) {
            my ( $i, $j ) = @$size;
            $i -= $j;
            $regex = qr/^ [0-9]{0,$i} (?: \. [0-9]{0,$j} )? \z/x;
        }
        elsif ( 'ARRAY' eq ref $size && 1 == @$size ) {
            my ($i) = @$size;
            $regex = qr/^ [0-9]{0,$i} \z/x;
        }
        elsif ( 0 == $size ) {
            $regex = qr/^ [0-9]+ \z/x;
        }
        elsif ( $size =~ /^[0-9]+\z/ ) {
            $regex = qr/^ [0-9]{0,$size} \z/x;
        }
    }

    $regex ||= qr/^ [0-9]+ (?: \. [0-9]+ )? \z/x;

    map { $_->constraint( { type => 'Regex', regex => $regex } ) } @$fields;
}

1;
