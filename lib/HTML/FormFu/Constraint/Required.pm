package HTML::FormFu::Constraint::Required;

use strict;
use warnings;
use base 'HTML::FormFu::Constraint';

sub validate_value {
    my ( $self, $value ) = @_;

    return defined $value && length $value;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::Required - Required constraint

=head1 SYNOPSIS

    $form->constraint( Required => 'foo' );

=head1 DESCRIPTION

Required constraint.

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

Based on the original source code of L<HTML::Widget::Constraint::All>, by 
Sebastian Riedel, C<sri@oook.de>.

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
