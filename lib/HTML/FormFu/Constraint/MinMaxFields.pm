package HTML::FormFu::Constraint::MinMaxFields;

use strict;
use warnings;
use base 'HTML::FormFu::Constraint::_others';

__PACKAGE__->mk_accessors(qw/ minimum maximum /);

*min = \&minimum;
*max = \&maximum;

sub new {
    my $self = shift->SUPER::new(@_);

    $self->attach_errors_to_base(1);

    return $self;
}

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

    for my $name (@names) {
        my $value = $params->{$name};
        if ( ref $value ) {
            eval { my @x = @$value };
            croak $@ if $@;

            my @errors = eval {
                $self->constrain_values( $value, $params );
                };
            $count++ if !@errors && !$@;
        }
        else {
            my $ok = eval {
                $self->constrain_value($value);
                };
            $count++ if $ok && !$@;
        }
    }

    return $self->mk_errors({
        pass   => ( $count < $min || $count > $max ) ? 0 : 1,
        failed => \@names,
        names  => \@names,
    });
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

HTML::FormFu::Constraint::MinMaxFields

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

=head2 attach_errors_to_base

Default Value: 1

=head2 attach_errors_to_others

Default Value: 1

=head1 SEE ALSO

Is a sub-class of, and inherits methods from  
L<HTML::FormFu::Constraint::_others>, L<HTML::FormFu::Constraint>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Mario Minati C<mario.minati@googlemail.com>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
