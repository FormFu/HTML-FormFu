package HTML::FormFu::Processor;

use strict;
use Class::C3;

use HTML::FormFu::Attribute qw(
    mk_item_accessors
    mk_accessors
    mk_output_accessors
);
use HTML::FormFu::ObjectUtil qw(
    populate                form
    name                    nested_name
    nested_names            get_nested_hash_value
    set_nested_hash_value   nested_hash_key_exists parent );

use Scalar::Util qw( refaddr );
use Carp qw( croak );

use overload
    'eq' => sub { refaddr $_[0] eq refaddr $_[1] },
    '==' => sub { refaddr $_[0] eq refaddr $_[1] },
    bool => sub {1},
    fallback => 1;

__PACKAGE__->mk_item_accessors( qw( type ) );

__PACKAGE__->mk_output_accessors( qw( message ) );

*field = \&parent;

sub new {
    my $class = shift;

    my %attrs;
    eval { %attrs = %{ $_[0] } if @_ };
    croak "attributes argument must be a hashref" if $@;

    my $self = bless {}, $class;

    for (qw( type )) {
        croak "$_ attribute required" if !exists $attrs{$_};
    }

    if ( exists $attrs{parent} ) {
        $self->parent( delete $attrs{parent} );
    }

    $self->populate( \%attrs );

    return $self;
}

sub localize_args {
    my $self = shift;
    
    if (@_) {
        # user's passing their own args - save them
        if ( @_ == 1 ) {
            $self->{localize_args} = $_[0];
        }
        else {
            $self->{localize_args} = [@_];
        }
        return $self;
    }
    
    # if the user passed a value, use that - even if it's undef
    if ( exists $self->{localize_args} ) {
        return $self->{localize_args};
    }
    
    # do we have a method to build our own args?
    if ( my $method = $self->can('_localize_args') ) {
        return $self->$method;
    }
    
    return;
}

sub clone {
    my ($self) = @_;

    my %new = %$self;

    return bless \%new, ref $self;
}

1;

__END__

=head1 NAME

HTML::FormFu::Processor - base class for constraints

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
