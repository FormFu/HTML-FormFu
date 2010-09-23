package HTML::FormFu::Role::Element::FieldMethods;
use Moose::Role;

use Carp qw( croak );

sub nested_name {
    my ($self) = @_;

    croak 'cannot set nested_name' if @_ > 1;

    return if !defined $self->name;

    my @names = $self->nested_names;

    if ( $self->form->nested_subscript ) {
        my $name = shift @names;
        map { $name .= "[$_]" } @names;
# TODO - Mario Minati 19.05.2009
# Does this (name formatted as '[name]') collide with FF::Model::HashRef as
# it uses /_\d/ to parse repeatable names?
        return $name;
    }
    else {
        return join ".", @names;
    }
}

sub add_error {
    my ( $self, @errors ) = @_;

    push @{ $self->_errors }, @errors;

    return;
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

sub validator {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { _single_validator( $self, $_ ) } @$arg;
    }
    else {
        push @return, _single_validator( $self, $arg );
    }

    return @return == 1 ? $return[0] : @return;
}

sub transformer {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { _single_transformer( $self, $_ ) } @$arg;
    }
    else {
        push @return, _single_transformer( $self, $arg );
    }

    return @return == 1 ? $return[0] : @return;
}

sub plugin {
    my ( $self, $arg ) = @_;
    my @return;

    if ( ref $arg eq 'ARRAY' ) {
        push @return, map { _single_plugin( $self, $_ ) } @$arg;
    }
    else {
        push @return, _single_plugin( $self, $arg );
    }

    return @return == 1 ? $return[0] : @return;
}

BEGIN {
    *constraints  = \&constraint;
    *filters      = \&filter;
    *deflators    = \&deflator;
    *inflators    = \&inflator;
    *validators   = \&validator;
    *transformers = \&transformer;
    *plugins      = \&plugin;
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

    my @return;

    my $type = delete $arg->{type};

    my $new = $self->_require_deflator( $type, $arg );

    push @{ $self->_deflators }, $new;

    return $new;
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

    my @return;

    my $type = delete $arg->{type};

    my $new = $self->_require_filter( $type, $arg );

    push @{ $self->_filters }, $new;

    return $new;
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

    my @return;

    my $type = delete $arg->{type};

    my $new = $self->_require_constraint( $type, $arg );

    push @{ $self->_constraints }, $new;

    return $new;
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

    my @return;

    my $type = delete $arg->{type};

    my $new = $self->_require_inflator( $type, $arg );

    push @{ $self->_inflators }, $new;

    return $new;
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

    my @return;

    my $type = delete $arg->{type};

    my $new = $self->_require_validator( $type, $arg );

    push @{ $self->_validators }, $new;

    return $new;
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

    my @return;

    my $type = delete $arg->{type};

    my $new = $self->_require_transformer( $type, $arg );

    push @{ $self->_transformers }, $new;

    return $new;
}

sub _single_plugin {
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

    my @return;

    my $type = delete $arg->{type};

    my $new = $self->_require_plugin( $type, $arg );

    push @{ $self->_plugins }, $new;

    return $new;
}

1;
