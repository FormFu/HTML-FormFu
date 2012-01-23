package HTML::FormFu::Inflator::Callback;

use Moose;
use MooseX::Attribute::Chained;
extends 'HTML::FormFu::Inflator';

has callback => ( is => 'rw', traits  => ['Chained'] );

sub inflator {
    my ( $self, $value ) = @_;

    my $callback = $self->callback || sub {shift};

    no strict 'refs';

    return $callback->($value);
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::Inflator::Callback - Callback inflator

=head1 SYNOPSIS

    $field->inflator('Callback')->callback( \&my_callback );

    ---
    elements:
      - type: Text
        name: foo
        inflators:
          - type: Callback
            callback: "main::my_inflator"

=head1 DESCRIPTION

Callback inflator.

=head1 METHODS

=head2 callback

Arguments: \&code-reference

Arguments: "subroutine-name"

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Inflator>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
