package HTML::FormFu::Constraint::Range;

use strict;
use warnings;
use base 'HTML::FormFu::Constraint';

use Scalar::Util qw( looks_like_number );

__PACKAGE__->mk_accessors(qw/minimum maximum/);

*min = \&minimum;
*max = \&maximum;

sub constrain_value {
    my ( $self, $value ) = @_;

    return 1 if !defined $value || $value eq '';

    my $min = $self->minimum;
    my $max = $self->maximum;

    return if !looks_like_number($value);

    if ( defined $min ) {
        return 0 if $value < $min;
    }

    if ( defined $max ) {
        return 0 if $value > $max;
    }

    return 1;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::Range

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

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
