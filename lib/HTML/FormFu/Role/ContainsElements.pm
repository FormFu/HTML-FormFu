use strict;

package HTML::FormFu::Role::ContainsElements;
# ABSTRACT: Role for contained elements and fields

use Moose::Role;

use HTML::FormFu::Util qw(
    _parse_args
    _get_elements
    _filter_components
);
use Carp qw( croak );
use Scalar::Util qw( refaddr weaken );

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

sub clear_errors {
    my ($self) = @_;

    map { $_->clear_errors } @{ $self->_elements };

    return;
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

1;
