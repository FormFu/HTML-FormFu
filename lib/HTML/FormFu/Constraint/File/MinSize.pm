package HTML::FormFu::Constraint::File::MinSize;

use strict;
use base 'HTML::FormFu::Constraint::File::Size';

sub _localize_args {
    my ($self) = @_;

    return $self->min;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::File::MinSize - Minimum File Size Constraint

=head1 DESCRIPTION

Ensure that an uploaded file meets minimum size constraints.

Overrides L<HTML::FormFu::Constraint/localize_args>, so that the value of 
L</minimum> is passed as an argument to L<localize|HTML::FormFu/localize>.

This constraint doesn't honour the C<not()> value.

=head1 METHODS

=head2 minimum

=head2 min

The minimum file size in bytes.

L</min> is an alias for L</minimum>.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::File::Size>, 
L<HTML::FormFu::Constraint>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
