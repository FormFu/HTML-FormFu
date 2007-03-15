package HTML::FormFu::Constraint::Callback;

use strict;
use warnings;
use base 'HTML::FormFu::Constraint';

__PACKAGE__->mk_accessors(qw/ callback /);

sub validate_value {
    my ( $self, $value ) = @_;

    my $callback = $self->callback || sub {1};

    my $ok = $callback->($value);

    return $ok;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::Callback - Callback constraint

=head1 SYNOPSIS

    $form->constraint( Callback => 'foo' )->callback(
        sub {
            my ($value) = @_;
            # do something, return 1 or 0
        }
    );

=head1 DESCRIPTION

Callback constraint.

This constraint doesn't honour the C<not()> value.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu::FormFu>

=head1 LIMITATIONS

The callback code-ref is copied internally using L<Storable/dclone>. It 
seems that because of this, the coderef does not act as a true closure, and 
cannot refer to variables and subroutines that would otherwise be in scope. 
This need further investigation.

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
