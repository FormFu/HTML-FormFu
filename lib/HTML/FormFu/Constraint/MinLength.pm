package HTML::FormFu::Constraint::MinLength;

use strict;
use warnings;
use base 'HTML::FormFu::Constraint::Length';

sub localize_args {
    my ($self) = @_;
    
    return $self->min;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::MinLength

=head1 DESCRIPTION

Checks the input value meets a minimum length.

Overrides L<HTML::FormFu::Constraint/localize_args>, so that the value of 
L</minimum> is passed as an argument to L<localize|HTML::FormFu/localize>.

This constraint doesn't honour the C<not()> value.

=head1 METHODS

=head2 minimum

=head2 min

The minimum input string length.

L</min> is an alias for L</minimum>.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Length>, 
L<HTML::FormFu::Constraint>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
