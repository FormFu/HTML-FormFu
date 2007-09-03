package HTML::FormFu::Filter::Default;

use strict;
use base 'HTML::FormFu::Filter';

__PACKAGE__->mk_accessors(qw/ value /);

sub filter {
    my ( $self, $value ) = @_;

    $value = $self->value if !defined $value || $value eq '';

    return $value;
}

1;

__END__

=head1 NAME

HTML::FormFu::Filter::Default

=head1 DESCRIPTION

Provide a default value for when the user doesn't provide a value.

Useful for a L<Checkbox field|HTML::FormFu::Element::Checkbox> in 
combination with L<DBIx::Class::HTML::FormFu>. - If your database column 
must be defined C<NOT NULL>, an unchecked Checkbox will cause an error 
when L<DBIx::Class::HTML::FormFu/populate_from_formfu> attempts to set 
the database column to C<undef>. Providing a default value with this filter 
will solve that problem.

=head1 METHODS

=head2 value

Arguments: $value

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
