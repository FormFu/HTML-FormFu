package HTML::FormFu::Constraint::File::Size;

use strict;
use base 'HTML::FormFu::Constraint';

use Scalar::Util qw( blessed );

__PACKAGE__->mk_accessors(qw/ minimum maximum /);

*min = \&minimum;
*max = \&maximum;

sub constrain_value {
    my ( $self, $value ) = @_;

    return 1 if !defined $value || $value eq '';

    return unless blessed($value) && $value->isa('HTML::FormFu::Upload');

    my $min = $self->minimum;
    my $max = $self->maximum;

    my $size = $value->size || 0;

    if ( defined $min ) {
        return 0 if $size < $min;
    }

    if ( defined $max ) {
        return 0 if $size > $max;
    }

    return 1;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::File::Size - File Size Constraint

=head1 DESCRIPTION

Ensure that an uploaded file meets minimum or maximum size constraints.

=head1 METHODS

=head2 minimum

=head2 min

Optional.

The minimum file size in bytes.

L</min> is an alias for L</minimum>.

=head2 maximum

=head2 max

Optional.

The maximum file size in bytes.

L</max> is an alias for L</maximum>.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
