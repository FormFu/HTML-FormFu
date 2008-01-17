package HTML::FormFu::Constraint::File;

use strict;
use base 'HTML::FormFu::Constraint';

use Scalar::Util qw( blessed );

sub constrain_value {
    my ( $self, $value ) = @_;

    return 1 if !defined $value || $value eq '';

    return blessed($value) && $value->isa('HTML::FormFu::Upload');
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::File - File Upload Constraint

=head1 DESCRIPTION

Ensure the submitted value is a file.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
