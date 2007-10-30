package HTML::FormFu::Transformer::Callback;

use strict;
use base 'HTML::FormFu::Transformer';

__PACKAGE__->mk_accessors(qw/ callback /);

sub transformer {
    my ( $self, $value ) = @_;

    my $callback = $self->callback || sub {1};

    no strict 'refs';

    my $return = $callback->($value);

    return $return;
}

1;

__END__

=head1 NAME

HTML::FormFu::Transformer::Callback - Callback transformer

=head1 SYNOPSIS

    $field->transformer('Callback')->callback( \&my_transformer );

    ---
    elements:
      - type: Text
        name: foo
        transformers:
          - type: Callback
            callback: "main::my_transformer"

=head1 DESCRIPTION

Callback transformer.

=head1 METHODS

=head2 callback

Arguments: \&code-reference

Arguments: "subroutine-name"

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Transformer>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
