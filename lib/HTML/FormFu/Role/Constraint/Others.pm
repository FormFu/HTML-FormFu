package HTML::FormFu::Role::Constraint::Others;
use Moose::Role;

use HTML::FormFu::Util qw(
    DEBUG_CONSTRAINTS
    debug
);
use Clone ();
use List::MoreUtils qw( any none );

has others                  => ( is => 'rw', traits => ['Chained'] );
has other_siblings          => ( is => 'rw', traits => ['Chained'] );
has attach_errors_to        => ( is => 'rw', traits => ['Chained'] );
has attach_errors_to_base   => ( is => 'rw', traits => ['Chained'] );
has attach_errors_to_others => ( is => 'rw', traits => ['Chained'] );

sub pre_process {
    my ($self) = @_;

    if ( $self->other_siblings ) {

        my $field = $self->field;
        my $block = $field;

        # find the nearest parent that contains any field other than
        # the one this constraint is attached to
        while ( defined( my $parent = $block->parent ) ) {
            $block = $parent;

            last if grep { $_ ne $field } @{ $block->get_fields };
        }

        my @names;

        for my $sibling ( @{ $block->get_fields } ) {
            next if $sibling == $field;

            push @names, $sibling->nested_name;
        }

        $self->others( [@names] );
    }
}

after repeatable_repeat => sub {
    my ( $self, $repeatable, $new_block ) = @_;

    my $block_fields = $new_block->get_fields;

    # rename any 'others' fields
    {
        my $others = $self->others;
        if ( !ref $others ) {
            $others = [$others];
        }
        my @new_others;

        for my $name (@$others) {
            my $field = $repeatable->get_field_with_original_name( $name,
                $block_fields );

            if ( defined $field ) {
                DEBUG_CONSTRAINTS && debug(
                    sprintf
                        "Repeatable renaming constraint 'other' '%s' to '%s'",
                    $name, $field->nested_name,
                );

                push @new_others, $field->nested_name;
            }
            else {
                push @new_others, $name;
            }
        }

        $self->others( \@new_others );
    }

    # rename any 'attach_errors_to' fields
    if ( my $others = $self->attach_errors_to ) {
        my @new_others;

        for my $name (@$others) {
            my $field = $repeatable->get_field_with_original_name( $name,
                $block_fields );

            if ( defined $field ) {
                DEBUG_CONSTRAINTS && debug(
                    sprintf
                        "Repeatable renaming constraint 'attach_errors_to' '%s' to '%s'",
                    $name, $field->nested_name,
                );

                push @new_others, $field->nested_name;
            }
            else {
                push @new_others, $name;
            }
        }

        $self->attach_errors_to( \@new_others );
    }
};

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

around clone => sub {
    my ( $orig, $self, $args ) = @_;

    my $clone = $self->$orig($args);

    if ( ref $self->others ) {
        $clone->others( Clone::clone( $self->others ) );
    }

    return $clone;
};

1;

__END__

=head1 NAME

HTML::FormFu::Role::Constraint::Others - Base class for constraints needing others() method

=head1 METHODS

=head2 others

Arguments: \@nested_names

=head2 other_siblings

Arguments: $bool

If true, the L</others> list will be automatically generated from the
C<nested_name> of all fields which are considered siblings of the field the
constraint is attached to.

Sibling are found by searching up through the field's parental hierarchy for
the first block containing any other field. All fields attached at any depth
to this block are considered siblings.

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
