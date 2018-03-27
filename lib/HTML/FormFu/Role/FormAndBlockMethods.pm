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

    $self->constraint(
        {   type => 'MaxLength',
            name => $col,
            max  => $info->{size},
        } );
}

sub _add_constraint_integer {
    my ( $self, $col, $info ) = @_;

    $self->constraint(
        {   type => 'Integer',
            name => $col,
        } );
}

sub _add_constraint_unsigned {
    my ( $self, $col, $info ) = @_;

    $self->constraint(
        {   type => 'Range',
            name => $col,
            min  => 0,
        } );
}

sub _add_constraint_set {
    my ( $self, $col, $info ) = @_;

    $self->constraint(
        {   type => 'Set',
            name => $col,
            set  => $info->{extra}{list},
        } );
}

1;
