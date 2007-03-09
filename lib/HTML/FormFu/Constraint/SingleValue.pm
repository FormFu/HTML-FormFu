package HTML::FormFu::Constraint::SingleValue;

use strict;
use warnings;
use base 'HTML::FormFu::Constraint';

sub validate_values {
    my ( $self, $values ) = @_;

    return 0;
}

sub validate_value {
    return 1;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::SingleValue - SingleValue constraint

=head1 DESCRIPTION

Ensures that multiple values were not submitted for the named element.

This constraint doesn't honour the C<not()> value, as it wouldn't make much 
sense.

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
