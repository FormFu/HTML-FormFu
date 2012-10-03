package HTML::FormFu::QueryType::Catalyst;
use Moose;
use MooseX::Attribute::Chained;

extends 'HTML::FormFu::Upload';

use IO::File ();
use Scalar::Util qw( weaken );

has basename => ( is => 'rw', traits => ['Chained'] );
has tempname => ( is => 'rw', traits => ['Chained'] );

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
                parent   => $form,
                basename => $upload->basename,
                headers  => $upload->headers,
                filename => $upload->filename,
                tempname => $upload->tempname,
                size     => $upload->size,
                type     => $upload->type
            } );

        push @new, $param;
    }

    return if !@new;

    return @new == 1 ? $new[0] : \@new;
}

# copied from Catalyst 5.7x series - before it was Moosified
sub fh {
    my $self = shift;

    my $fh = IO::File->new( $self->tempname, IO::File::O_RDONLY );

    unless ( defined $fh ) {

        my $filename = $self->tempname;

        Catalyst::Exception->throw(
            message => qq/Can't open '$filename': '$!'/ );
    }

    return $fh;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::QueryType::Catalyst

=head1 DESCRIPTION

If you use L<Catalyst::Controller::HTML::FormFu>, it will automatically set
L<HTML::FormFu/query_type> to C<Catalyst>.

=head1 METHODS

=head2 headers

=head2 filename

=head2 fh

=head2 slurp

=head2 basename

=head2 size

=head2 tempname

=head2 type

=head1 REMOVED METHODS

=head2 catalyst_upload

We no longer keep a reference to the
L<Catalyst::Request::Upload|Catalyst::Request::Upload> object, as it
was causing issues under L<HTML::FormFu::MultiForm|HTML::FormFu::MultiForm>
after the L<Catalyst|Catalyst> 5.8 move to L<Moose|Moose>.

=head2 copy_to

Because L</catalyst_upload> has been removed, we can no-longer call this
L<Catalyst::Request::Upload|Catalyst::Request::Upload> method.

=head2 link_to

Because L</catalyst_upload> has been removed, we can no-longer call this
L<Catalyst::Request::Upload|Catalyst::Request::Upload> method.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Upload>

L<HTML::FormFu>, L<HTML::FormFu::Element::File>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
