package HTML::FormFu::Filter::CopyValue;

use strict;
use base 'HTML::FormFu::Filter';

__PACKAGE__->mk_accessors(qw/ field /);

sub filter {
    my ( $self, $value ) = @_;

    return $value
        if ( defined $value && length $value );

    my $field_name = $self->field
        or die "Parameter 'field' is not defined.";

    my $parent = $self->parent
        or die "Can't determine my parent.";

    my $field_value = $parent->form->input->{$field_name};

    return $field_value;
}

1;

__END__

=head1 NAME

HTML::FormFu::Filter::CopyValue - copy the value from an other field

=head1 SYNOPSIS

   elements:
      - type: Text
        name: username
      - type: Text
        name: nickname
        filters:
           - type: CopyValue
             field: username

=head1 DESCRIPTION

Filter copying the value of another field if the original value of this field
is empty.

=head1 CAVEATS

If the value of the original field contains an invalid value (a value that
will be constrained through a constraint) this invalid value will be choosen
for this field (the field with CopyValue filter).

So the user has to change two fields or you remove the invalid value in a
custom constraint.

=head1 AUTHOR

Mario Minati, C<mario.minati@googlemail.com>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
