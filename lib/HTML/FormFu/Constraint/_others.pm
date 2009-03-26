package HTML::FormFu::Constraint::_others;

use strict;
use base 'HTML::FormFu::Constraint';
use Class::C3;

use HTML::FormFu::Util qw(
    DEBUG_CONSTRAINTS
    debug
);
use List::MoreUtils qw( any none );
use Storable qw( dclone );

__PACKAGE__->mk_item_accessors( qw(
        attach_errors_to_base
        attach_errors_to_others
) );

__PACKAGE__->mk_accessors( qw(
        others
        attach_errors_to
) );

sub mk_errors {
    my ( $self, $args ) = @_;

    my $pass   = $args->{pass};
    my @failed = $args->{failed} ? @{ $args->{failed} } : ();
    my @names  = $args->{names} ? @{ $args->{names} } : ();

    my $force = $self->force_errors || $self->parent->force_errors;

    DEBUG_CONSTRAINTS && debug( PASS           => $pass );
    DEBUG_CONSTRAINTS && debug( NAMES          => \@names );
    DEBUG_CONSTRAINTS && debug( 'FAILED NAMES' => \@failed );
    DEBUG_CONSTRAINTS && debug( FORCE          => $force );

    if ( $pass && !$force ) {
        DEBUG_CONSTRAINTS
            && debug(
            'constraint passed, or force_errors is false - returning no errors'
            );
        return;
    }

    my @can_error;
    my @has_error;

    if ( $self->attach_errors_to ) {
        push @can_error, @{ $self->attach_errors_to };

        if ( !$pass ) {
            push @has_error, @{ $self->attach_errors_to };
        }
    }
    elsif ( $self->attach_errors_to_base ) {
        push @can_error, $self->nested_name;

        if ( !$pass ) {
            push @has_error, $self->nested_name;
        }
    }
    elsif ( $self->attach_errors_to_others ) {
        push @can_error, ref $self->others
            ? @{ $self->others }
            : $self->others;

        if ( !$pass ) {
            push @has_error, ref $self->others
                ? @{ $self->others }
                : $self->others;
        }
    }
    else {
        push @can_error, @names;

        if ( !$pass ) {
            push @has_error, @failed;
        }
    }

    DEBUG_CONSTRAINTS && debug( 'CAN ERROR' => \@can_error );
    DEBUG_CONSTRAINTS && debug( 'HAS ERROR' => \@has_error );

    my @errors;

    for my $name (@can_error) {

        next unless $force || grep { $name eq $_ } @has_error;

        DEBUG_CONSTRAINTS && debug( 'CREATING ERROR' => $name );

        my $field = $self->form->get_field( { nested_name => $name } )
            or die "others() field not found: '$name'";

        my $error = $self->mk_error;

        $error->parent($field);

        if ( !grep { $name eq $_ } @has_error ) {
            DEBUG_CONSTRAINTS && debug("setting '$name' error forced(1)");

            $error->forced(1);
        }

        push @errors, $error;
    }

    return @errors;
}

sub clone {
    my $self = shift;

    my $clone = $self->next::method(@_);

    if ( ref $self->others ) {
        $clone->others( dclone $self->others );
    }

    return $clone;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::_others - Base class for constraints needing others() method

=head1 METHODS

=head2 others

Arguments: \@nested_names

=head2 attach_errors_to_base

If true, any error will cause the error message to be associated with the 
field the constraint is attached to.

Can be use in conjunction with L</attach_errors_to_others>.

Is ignored if L</attach_errors_to> is set.

=head2 attach_errors_to_others

If true, any error will cause the error message to be associated with every 
field named in L</others>.

Can be use in conjunction with L</attach_errors_to_base>.

Is ignored if L</attach_errors_to> is set.

=head2 attach_errors_to

Arguments: \@field_names

Any error will cause the error message to be associated with every field 
named in L</attach_errors_to>.

Overrides L</attach_errors_to_base> and L</attach_errors_to_others>.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
