use strict;

package HTML::FormFu::Filter::Default;
# ABSTRACT: default filter value

use Moose;
use MooseX::Attribute::Chained;
extends 'HTML::FormFu::Filter';

has value => ( is => 'rw', traits => ['Chained'] );

sub filter {
    my ( $self, $value ) = @_;

    $value = $self->value if !defined $value || $value eq '';

    return $value;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 DESCRIPTION

Provide a default value for when the user doesn't provide a value.

=head1 METHODS

=head2 value

Arguments: $value

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
