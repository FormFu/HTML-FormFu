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

Ensure the submitted value is a file upload.

This Constraint is not needed if you use any of the C<File::*> Constraints, 
as they all make the same check as this Constraint does.

=head1 LIMITATIONS

This can only verify that your CGI backend (CGI, Catalyst, CGI::Simple) 
thinks it was a file upload. If the user submits a filename which doesn't 
exist on their system, you will probably get a valid L<HTML::FormFu::Upload> 
object, with a valid filehandle, but no Content-Length. This Constraint 
would still see this as a valid uploaded file - if you want to ensure that 
you get a file with content, instead use 
L<HTML::FormFu::Constraint::File::Size> with 
L<min/HTML::FormFu::Constraint::File::Size/min> set to C<1>.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
