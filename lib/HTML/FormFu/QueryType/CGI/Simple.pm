package HTML::FormFu::QueryType::CGI::Simple;

use strict;
use base 'HTML::FormFu::QueryType::CGI';

sub parse_uploads {
    my ( $class, $form, $name ) = @_;

    my $query  = $form->query;
    my @params = $query->param($name);
    my @new;

    for my $param (@params) {
        if ( my $file = $query->upload($param) ) {
            my $filename = $param;

            $param = $class->new( {
                    _param   => $file,
                    filename => $filename,
                    parent   => $form,
                } );

            my $headers = HTTP::Headers->new(
                'Content-Type'   => $query->upload_info( $filename, 'mime' ),
                'Content-Length' => $query->upload_info( $filename, 'size' ),
            );

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

    return $self->form->query->upload( $self->filename );
}

1;

__END__

=head1 NAME

HTML::FormFu::QueryType::CGI::Simple

=head1 METHODS

=head2 headers

Inherited, see L<HTML::FormFu::QueryType::CGI/headers> for details.

=head2 filename

Inherited, see L<HTML::FormFu::QueryType::CGI/filename> for details.

=head2 fh

Returns a read-only filehandle.

=head2 slurp

Inherited, see L<HTML::FormFu::QueryType::CGI/slurp> for details.

=head2 size

Inherited, see L<HTML::FormFu::QueryType::CGI/size> for details.

=head2 type

Inherited, see L<HTML::FormFu::QueryType::CGI/type> for details.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::QueryType::CGI>, L<HTML::FormFu::Upload>

L<HTML::FormFu::FormFu>, L<HTML::FormFu::Element::File>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
