use strict;
package HTML::FormFu::Constraint::Set;


use Moose;
use MooseX::Attribute::FormFuChained;
extends 'HTML::FormFu::Constraint';

use Clone ();

has set => ( is => 'rw', traits => ['FormFuChained'] );

sub constrain_value {
    my ( $self, $value ) = @_;

    return 1 if !defined $value || $value eq '';

    my $set = $self->set;

    my %set = map { $_ => 1 } @$set;

    return exists $set{$value};
}

sub clone {
    my $self = shift;

    my $clone = $self->SUPER::clone(@_);

    if ( $self->set ) {
        $clone->set( Clone::clone( $self->set ) );
    }

    return $clone;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::Set - Set of Values Constraint

=head1 SYNOPSIS

    type: Set
    set: [yes, no]

=head1 DESCRIPTION

The input value must be in the specified set of values.

=head1 METHODS

=head2 set

Arguments: \@allowed_values

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
