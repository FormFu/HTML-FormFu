package HTML::FormFu::Constraint::MaxRange;

use strict;
use base 'HTML::FormFu::Constraint::Range';

sub _localize_args {
    my ($self) = @_;

    return $self->max;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::MaxRange - Maximum Value Constraint

=head1 DESCRIPTION

Checks the input value is equal to or less than a maximum value.

Overrides L<HTML::FormFu::Constraint/localize_args>, so that the value of 
L</maximum> is passed as an argument to L<localize|HTML::FormFu/localize>.

This constraint doesn't honour the C<not()> value.

=head1 METHODS

=head2 maximum

=head2 max

The maximum input value.

L</max> is an alias for L</maximum>.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Range>, 
L<HTML::FormFu::Constraint>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
