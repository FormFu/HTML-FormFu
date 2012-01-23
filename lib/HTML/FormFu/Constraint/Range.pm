package HTML::FormFu::Constraint::Range;
use Moose;
use MooseX::Attribute::Chained;
use MooseX::Aliases;

extends 'HTML::FormFu::Constraint';

use Scalar::Util qw( looks_like_number );

has minimum => (
    is      => 'rw',
    alias   => 'min',
    traits  => ['Chained'],
);

has maximum => (
    is      => 'rw',
    alias   => 'max',
    traits  => ['Chained'],
);

sub constrain_value {
    my ( $self, $value ) = @_;

    return 1 if !defined $value || $value eq '';

    return if !looks_like_number($value);

    if ( defined( my $min = $self->minimum ) ) {
        return 0 if $value < $min;
    }

    if ( defined( my $max = $self->maximum ) ) {
        return 0 if $value > $max;
    }

    return 1;
}

sub _localize_args {
    my ($self) = @_;

    return $self->min, $self->max;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::Range - Numerical Range Constraint

=head1 SYNOPSIS

    type: Range
    min: 18
    max: 35

=head1 DESCRIPTION

Numerical range constraint.

This constraint doesn't honour the C<not()> value.

=head1 METHODS

=head2 minimum

=head2 min

If defined, the input value must be equal to or greater than this.

L</min> is an alias for L</minimum>.

=head2 maximum

=head2 max

If defined, the input value must be equal to or less than this.

L</max> is an alias for L</maximum>.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
