package HTML::FormFu::Constraint::MinMaxNeeded;

use strict;
use warnings;
use base 'HTML::FormFu::Constraint';

use Storable qw/ dclone /;

__PACKAGE__->mk_accessors(qw/ minimum maximum others /);

*min = \&minimum;
*max = \&maximum;

sub process {
    my ( $self, $params ) = @_;
    my $count = 0;

    # others are needed
    my $others = $self->others;
    return if !defined $others;

    # get min/max values
    my $min = $self->minimum;
    $min = 1 if !defined $min;
    my $max = $self->maximum;
    $max = 1 if !defined $max;

    # get field names to check
    my @names = ( $self->name );
    push @names, ref $others ? @{$others} : $others;
    my @errors;

    for my $name (@names) {
        my $value = $params->{$name};
        if ( ref $value ) {
            eval { my @x = @$value };
            croak $@ if $@;

            my @local_errors = eval {
                $self->constrain_values( $value, $params );
                };
            $count++ if !@local_errors && !$@;
        }
        else {
            my $ok = eval {
                $self->constrain_value($value);
                };
            $count++ if $ok && !$@;
        }
    }

    # check min/max values
    if ( $count < $min || $count > $max ) {

        # create exceptions
        for my $name (@names) {
            my $field = $self->form->get_field({ name => $name })
                or die "MinMaxNeeded->others() field not found: '$name'";

            push @errors, HTML::FormFu::Exception::Constraint->new({
                parent => $field,
                });
        }
    }

    return @errors;
}

# return true if value is defined
sub constrain_value {
    my ( $self, $value ) = @_;

    return 0 if !defined $value || $value eq '';

    return 1;
}

sub clone {
    my $self = shift;
    
    my $clone = $self->SUPER::clone(@_);
    
    $clone->{others} = dclone $self->others
        if ref $self->others;
    
    return $clone;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::MinMaxNeeded

=head1 SYNOPSIS

    type: MinMaxNeeded
    name: foo
    others: [bar, baz]
    min: 1
    max: 1

=head1 DESCRIPTION

Ensure that at least a minimum and only a maximum number of fields are 
present.

This constraint doesn't honour the C<not()> value.

=head1 METHODS

=head2 others

Arguments: \@field_names

A list of field names, which along with the field the constraint is related 
to, is used in processing the constraint.

=head2 minimum

=head2 min

The minimum number of named fields which must be filled in.

L</min> is an alias for L</minimum>.

=head2 maximum

=head2 max

The maximum number of named fields which must be filled in.

L</max> is an alias for L</maximum>.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Mario Minati C<mario.minati@googlemail.com>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
