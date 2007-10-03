package HTML::FormFu::Validator::Callback;

use strict;
use base 'HTML::FormFu::Validator';

__PACKAGE__->mk_accessors(qw/ callback /);

sub validate_value {
    my ( $self, $value ) = @_;

    my $callback = $self->callback || sub {1};

    no strict 'refs';

    my $ok = $callback->($value);

    return $ok;
}

1;

__END__

=head1 NAME

HTML::FormFu::Validator::Callback - Callback validator

=head1 SYNOPSIS

    $field->validator('Callback')->callback( \&my_validator );

    ---
    elements:
      - type: Text
        name: foo
        validators:
          - type: Callback
            callback: "main::my_validator"

=head1 DESCRIPTION

Callback validator.

=head1 METHODS

=head2 callback

Arguments: \&code-reference

Arguments: "subroutine-name"

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Validator>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
