use strict;
package HTML::FormFu::Constraint::AutoSet;
# ABSTRACT: Set Constraint for Selects / Radiogroups / Checkboxgroups


use Moose;
extends 'HTML::FormFu::Constraint::Set';

sub process {
    my $self = shift;

    my @set = map { _parse_value($_) } @{ $self->parent->_options };

    $self->set( \@set );

    return $self->SUPER::process(@_);
}

sub _parse_value {
    my ($item) = @_;

    if ( exists $item->{group} ) {
        return map { _parse_value($_) } @{ $item->{group} };
    }
    else {
        # disabled attributes should be ignored
        return if ($item->{attributes} and $item->{attributes}->{disabled});
        # anything else is fine
        return $item->{value};
    }
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 DESCRIPTION

For use with L<HTML::FormFu::Element::Radiogroup>,
L<HTML::FormFu::Element::Select> and L<HTML::FormFu::Element::Checkboxgroup>
fields.

Ensures that the input value is one of the pre-defined element options.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint::Set>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
