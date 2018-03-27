use strict;

package HTML::FormFu::Constraint::SingleValue;

# ABSTRACT: Single Value Constraint

use Moose;
extends 'HTML::FormFu::Constraint';

sub constrain_values {
    my ( $self, $values ) = @_;

    die;
}

sub constrain_value {
    return 1;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 DESCRIPTION

Ensures that multiple values were not submitted for the named element.

This constraint doesn't honour the C<not()> value.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
