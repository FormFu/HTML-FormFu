package HTML::FormFu::Constraint::Callback;

use Moose;
use MooseX::Attribute::Chained;
extends 'HTML::FormFu::Constraint';

has callback => ( is => 'rw', traits  => ['Chained'] );

sub constrain_value {
    my ( $self, $value, $params ) = @_;

    my $callback = $self->callback || sub {1};

    no strict 'refs';

    my $ok = $callback->( $value, $params );

    return $ok;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::Callback - Code Callback Constraint

=head1 SYNOPSIS

    $field->constraint({
        type => 'Callback',
        callback => \&foo,
    });

    ---
    elements:
      - type: Text
        name: foo
        constraints:
          - type: Callback
            callback: "main::my_constraint"

    sub foo {
        my ( $value, $params ) = @_;

        # return true or false
    }

=head1 DESCRIPTION

The first argument passed to the callback is the submitted value for the
associated field. The second argument passed to the callback is a hashref of
name/value pairs for all input fields.

This constraint doesn't honour the C<not()> value.

=head1 METHODS

=head2 callback

Arguments: \&code-reference

Arguments: "subroutine-name"

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
