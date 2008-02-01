package HTML::FormFu::QueryType::CGI;

use strict;
use base 'HTML::FormFu::Upload';

use HTTP::Headers;
use Scalar::Util qw/ blessed /;


sub parse_uploads {
    my ( $class, $form, $name ) = @_;

    my $query  = $form->query;
    my @params = $query->param($name);
    my @new;

    for my $param (@params) {
        if ( blessed $param ) {
            my $filename = $param;

            $param = $class->new( {
                    _param   => $param,
                    filename => sprintf( "%s", $filename ),
                    parent   => $form,
                    # TODO: for now, parent points to the form
                    # pointing to a field will require handling multiple
                    # fields of the same name
                    # if fixed, other QueryTypes and MultiForm will need updating
                } );

            my $headers
                = HTTP::Headers->new( %{ $query->uploadInfo($filename) } );

            $param->headers($headers);
            $param->size( $headers->content_length );
            $param->type( $headers->content_type );
        }

        push @new, $param;
    }

    return if !@new;

    return @new == 1 ? $new[0] : \@new;
}

sub fh {
    my ($self) = @_;

    return $self->_param;
}

sub slurp {
    my ($self) = @_;

    my $fh = $self->fh;

    return if !defined $fh;

    binmode $fh;

    local $/;

    return <$fh>;
}

1;

__END__

=head1 NAME

HTML::FormFu::QueryType::CGI

=head1 METHODS

=head2 headers

As of L<HTML::FormFu> version C<0.02004>, returns a L<HTTP::Headers> object.
- Previously returned a hashref of values.

=head2 filename

Returns the browser-submitted filename of the local file.

=head2 fh

Returns a read-only filehandle.

=head2 slurp

Returns the contents of the uploaded file.

=head2 size

A shortcut for C<< $upload->headers->content_length >>.

Returns the size of the uploaded file in bytes.

=head2 type

A shortcut for C<< $upload->headers->content_type >>.

Returns the browser-submitted Content-Type of the uploaded file.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Upload>

L<HTML::FormFu::FormFu>, L<HTML::FormFu::Element::File>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
