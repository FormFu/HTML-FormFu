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

HTML::FormFu::Constraint::MinLength - MinLength constraint

=head1 SYNOPSIS

=head1 DESCRIPTION

MinLength constraint.

This constraint doesn't honour the C<not()> value.

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
