package HTML::FormFu::Constraint::Length;

use strict;
use warnings;
use base 'HTML::FormFu::Constraint';

__PACKAGE__->mk_accessors(qw/minimum maximum/);

*min = \&minimum;
*max = \&maximum;

sub constrain_value {
    my ( $self, $value ) = @_;

    return 1 if !defined $value || $value eq '';

    my $min = $self->minimum;
    my $max = $self->maximum;

    if ( defined $min ) {
        return 0 if length $value < $min;
    }

    if ( defined $max ) {
        return 0 if length $value > $max;
    }

    return 1;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::Length

=head1 DESCRIPTION

Checks the input value meets both a minimum and maximum length.

This constraint doesn't honour the C<not()> value.

=head1 METHODS

=head2 minimum

=head2 min

The minimum input string length.

L</min> is an alias for L</minimum>.

=head2 maximum

=head2 max

The maximum input string length.

L</max> is an alias for L</maximum>.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
