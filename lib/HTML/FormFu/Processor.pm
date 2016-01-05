package HTML::FormFu::Processor;

use Moose;
use MooseX::Attribute::FormFuChained;

with 'HTML::FormFu::Role::NestedHashUtils',
    'HTML::FormFu::Role::HasParent',
    'HTML::FormFu::Role::Populate';

use HTML::FormFu::Attribute qw(
    mk_output_accessors
    mk_inherited_accessors
);
use HTML::FormFu::ObjectUtil qw(
    form
    name                    nested_name
    nested_names            parent );

has type => ( is => 'rw', traits => ['FormFuChained'] );

__PACKAGE__->mk_output_accessors(qw( message ));

__PACKAGE__->mk_inherited_accessors(qw( locale ));

*field = \&parent;

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

=cut
