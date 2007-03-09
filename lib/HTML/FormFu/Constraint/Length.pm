package HTML::FormFu::Constraint::Length;

use strict;
use warnings;
use base 'HTML::FormFu::Constraint';

__PACKAGE__->mk_accessors(qw/minimum maximum/);

*min = \&minimum;
*max = \&maximum;

sub validate_value {
    my ( $self, $value ) = @_;

    return 1 if !defined $value || $value eq '';

    my $min = $self->minimum;
    my $max = $self->maximum;

    if ( defined $min ) {
        return 0 if length $value < $min;
    }

    if ( defined $max ) {
        return 0 if length $value > $max;
    }

    return 1;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::Length - Length constraint

=head1 SYNOPSIS

    $form->constraint( Length => 'foo' )->min(3)->max(255);

=head1 DESCRIPTION

Length constraint.

This constraint doesn't honour the C<not()> value, as it wouldn't make much 
sense.

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
