package HTML::FormFu::Constraint::Email;

use strict;
use warnings;
use base 'HTML::FormFu::Constraint';

use Email::Valid;

sub constrain_value {
    my ( $self, $value ) = @_;

    return 1 if !defined $value || $value eq '';

    return Email::Valid->address( -address => $value ) ? 1 : 0;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::Email - Email constraint

=head1 SYNOPSIS

    $form->constraint( Email => 'foo' )->min(3)->max(255);

=head1 DESCRIPTION

Email constraint.

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
