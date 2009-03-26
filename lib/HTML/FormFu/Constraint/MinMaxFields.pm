package HTML::FormFu::Constraint::MinMaxFields;

use strict;
use base 'HTML::FormFu::Constraint::_others';
use Class::C3;

__PACKAGE__->mk_item_accessors(qw( minimum maximum ));

*min = \&minimum;
*max = \&maximum;

sub new {
    my $self = shift->next::method(@_);

    $self->attach_errors_to_base(1);

    return $self;
}

sub process {
    my ( $self, $params ) = @_;
    my $count = 0;

    # check when condition
    return if !$self->_process_when($params);

    # others are needed
    my $others = $self->others;
    return if !defined $others;

    # get field names to check
    my @names = ( $self->nested_name );
    push @names, ref $others ? @{$others} : $others;

    # get min/max values
    my $min
        = defined $self->minimum
        ? $self->minimum
        : 1;

    my $max
        = defined $self->maximum
        ? $self->maximum
        : scalar @names;

    for my $name (@names) {
        my $value = $self->get_nested_hash_value( $params, $name );

        if ( ref $value eq 'ARRAY' ) {
            my @errors = eval { $self->constrain_values( $value, $params ) };

            if ( !@errors && !$@ ) {
                $count++;
            }
        }
        else {
            my $ok = eval { $self->constrain_value($value) };

            if ( $ok && !$@ ) {
                $count++;
            }
        }
    }

    my $pass = ( $count < $min || $count > $max ) ? 0 : 1;

    return $self->mk_errors( {
            pass   => $pass,
            failed => $pass ? [] : \@names,
            names  => \@names,
        } );
}

# return true if value is defined
sub constrain_value {
    my ( $self, $value ) = @_;

    return 0 if !defined $value || $value eq '';

    return 1;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::MinMaxFields - Min/Max Multi-field Constraint

=head1 SYNOPSIS

    type: MinMaxFields
    name: foo
    others: [bar, baz]
    min: 1
    max: 1

=head1 DESCRIPTION

Ensure that at least a minimum and only a maximum number of fields are 
present.

This constraint doesn't honour the C<not()> value.

=head1 METHODS

=head2 minimum

=head2 min

The minimum number of named fields which must be filled in.

L</min> is an alias for L</minimum>.

=head2 maximum

=head2 max

The maximum number of named fields which must be filled in.

L</max> is an alias for L</maximum>.

The default for max is the number of all affected fields, in other words one
more than the number of elements given to others.

=head2 attach_errors_to_base

Default Value: 1

=head2 attach_errors_to_others

Default Value: 0

=head1 SEE ALSO

Is a sub-class of, and inherits methods from  
L<HTML::FormFu::Constraint::_others>, L<HTML::FormFu::Constraint>

L<HTML::FormFu>

=head1 AUTHOR

Mario Minati C<mario.minati@googlemail.com>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
