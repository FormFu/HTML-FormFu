package HTML::FormFu::Constraint::File::MIME;

use strict;
use base 'HTML::FormFu::Constraint';

use List::MoreUtils qw( any );
use Scalar::Util qw( blessed );

__PACKAGE__->mk_item_accessors(qw( regex ));

__PACKAGE__->mk_accessors(qw( types ));

sub constrain_value {
    my ( $self, $value ) = @_;

    return 1 if !defined $value || $value eq '';

    return if !blessed($value) || !$value->isa('HTML::FormFu::Upload');

    my $input = $value->headers->content_type;
    my $types = $self->types;
    my $regex = $self->regex;

    if ( defined $types ) {
        if ( ref $types ne 'ARRAY' ) {
            $types = [$types];
        }

        return 1 if any { $input eq $_ } @$types;
    }

    if ( defined $regex ) {
        return $input =~ /$regex/x;
    }

    return;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::File::MIME - MIME Type Constraint

=head1 DESCRIPTION

Constraint an uploaded file's MIME-type (Content-Type).

L</types> is checked before L</regex>.

=head1 METHODS

=head2 types

Arguments: $mime_type

Arguments: \@mime_types

Optional.

Accepts a single MIME-type or an arrayref of MIME-types. Each is checked 
against the uploaded file's MIME-type (as given by the browser), and the 
constraint passes if any one of the given types matches.

=head2 regex

Arguments: $regex

Optional.

Accepts a string to be interpreted as a regex, and is checked against the 
uploaded files's MIME-type (as given by the browser).

The regex uses the C</x> flag, so that whitespace in the given string is 
ignored.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
