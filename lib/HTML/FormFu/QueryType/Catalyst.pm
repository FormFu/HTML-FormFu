package HTML::FormFu::QueryType::Catalyst;

use strict;
use base 'HTML::FormFu::Upload';

use Scalar::Util qw/ weaken /;

sub parse_uploads {
    my ( $class, $form, $name ) = @_;

    my @params  = $form->query->param($name);
    my @uploads = $form->query->upload($name);
    my @new;

    # if all params aren't files,
    # the files will be at the end of @params
    my $non_file_count = scalar @params - scalar @uploads;

    if ( $non_file_count > 0 ) {
        splice @params, $non_file_count;

        push @new, @params;
    }

    for my $upload (@uploads) {
        my $param = $class->new( {
                _param          => $upload,
                catalyst_upload => $upload,
                parent          => $form,

             # set the following now, rather than on demand from catalyst_upload
             # so they'll still work if we're freeze/thawed and reblessed
             # as a HTML::FormFu::QueryType::CGI by MultiForm
                headers  => $upload->headers,
                filename => $upload->filename,
                size     => $upload->size,
                type     => $upload->type
            } );

        push @new, $param;
    }

    return if !@new;

    return @new == 1 ? $new[0] : \@new;
}

sub fh {
    my ($self) = @_;

    return $self->_param->fh;
}

sub slurp {
    my ( $self, $layer ) = @_;

    return $self->_param->slurp($layer);
}

sub basename {
    my ($self) = @_;

    return $self->_param->basename;
}

sub copy_to {
    my $self = shift;

    return $self->_param->copy_to(@_);
}

sub link_to {
    my ( $self, $target ) = @_;

    return $self->_param->link_to($target);
}

sub tempname {
    my ($self) = @_;

    return $self->_param->tempname;
}

sub catalyst_upload {
    my $self = shift;

    if (@_) {
        $self->{catalyst_upload} = shift;

        weaken( $self->{catalyst_upload} );
    }

    return $self->{catalyst_upload};
}

1;

__END__

=head1 NAME

HTML::FormFu::QueryType::Catalyst

=head1 DESCRIPTION

If you use L<Catalyst::Controller::HTML::FormFu>, it will automatically set
L<HTML::FormFu/query_type> to C<Catalyst>.

=head1 METHODS

=head2 headers

Delegates to L<Catalyst::Request::Upload/headers>.

=head2 filename

Delegates to L<Catalyst::Request::Upload/filename>.

=head2 fh

Delegates to L<Catalyst::Request::Upload/fh>.

=head2 slurp

Delegates to L<Catalyst::Request::Upload/slurp>.

=head2 basename

Delegates to L<Catalyst::Request::Upload/basename>.

=head2 copy_to

Delegates to L<Catalyst::Request::Upload/copy_to>.

=head2 link_to

Delegates to L<Catalyst::Request::Upload/link_to>.

=head2 size

Delegates to L<Catalyst::Request::Upload/size>.

=head2 tempname

Delegates to L<Catalyst::Request::Upload/tempname>.

=head2 type

Delegates to L<Catalyst::Request::Upload/name>.

=head2 catalyst_upload

Returns the original L<Catalyst::Request::Upload> object.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Upload>

L<HTML::FormFu::FormFu>, L<HTML::FormFu::Element::File>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
