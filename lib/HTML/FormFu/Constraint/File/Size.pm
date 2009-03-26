package HTML::FormFu::Constraint::File::Size;

use strict;
use base 'HTML::FormFu::Constraint';

use Carp qw( croak );
use Scalar::Util qw( blessed );

__PACKAGE__->mk_item_accessors(qw( minimum maximum ));

*min          = \&minimum;
*max          = \&maximum;
*min_kilobyte = \&minimum_kilobyte;
*max_kilobyte = \&maximum_kilobyte;
*min_megabyte = \&minimum_megabyte;
*max_megabyte = \&maximum_megabyte;

sub constrain_value {
    my ( $self, $value ) = @_;

    return 1 if !defined $value || $value eq '';

    return if !blessed($value) || !$value->isa('HTML::FormFu::Upload');

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

sub _localize_args {
    my ($self) = @_;

    return $self->min, $self->max;
}

sub minimum_kilobyte {
    my ( $self, $kb ) = @_;

    croak "minimum_kilobyte() cannot be used as a getter"
        if @_ != 2;

    return $self->minimum( $kb * 1024 );
}

sub minimum_megabyte {
    my ( $self, $kb ) = @_;

    croak "minimum_megabyte() cannot be used as a getter"
        if @_ != 2;

    return $self->minimum( $kb * 1_048_576 );
}

sub maximum_kilobyte {
    my ( $self, $kb ) = @_;

    croak "maximum_kilobyte() cannot be used as a getter"
        if @_ != 2;

    return $self->maximum( $kb * 1024 );
}

sub maximum_megabyte {
    my ( $self, $kb ) = @_;

    croak "maximum_megabyte() cannot be used as a getter"
        if @_ != 2;

    return $self->maximum( $kb * 1_048_576 );
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

=head2 minimum_kilobyte

=head2 min_kilobyte

Shortcut for C<< $constraint->minimum( $value * 1024 ) >>.

L</min_kilobyte> is an alias for L</minimum_kilobyte>.

=head2 maximum_kilobyte

=head2 max_kilobyte

Shortcut for C<< $constraint->maximum( $value * 1024 ) >>.

L</max_kilobyte> is an alias for L</maximum_kilobyte>.

=head2 minimum_megabyte

=head2 min_megabyte

Shortcut for C<< $constraint->minimum( $value * 1_048_576 ) >>.

L</min_megabyte> is an alias for L</minimum_megabyte>.

=head2 maximum_megabyte

=head2 max_megabyte

Shortcut for C<< $constraint->maximum( $value * 1_048_576 ) >>.

L</max_megabyte> is an alias for L</maximum_megabyte>.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
