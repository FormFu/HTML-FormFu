package HTML::FormFu::Upload;
use Moose;
use MooseX::Attribute::FormFuChained;

with 'HTML::FormFu::Role::Populate';

use Carp qw( croak );

use HTML::FormFu::ObjectUtil qw( form parent );
use HTML::FormFu::UploadParam;
use Scalar::Util qw( reftype );

has headers  => ( is => 'rw', traits => ['FormFuChained'] );
has filename => ( is => 'rw', traits => ['FormFuChained'] );
has size     => ( is => 'rw', traits => ['FormFuChained'] );
has type     => ( is => 'rw', traits => ['FormFuChained'] );

sub BUILD { }

sub _param {
    my ( $self, $param ) = @_;

    if ( @_ > 1 ) {
        $param = HTML::FormFu::UploadParam->new( { param => $param, } );

        $param->form( $self->form );

        $self->{_param} = $param;
    }

    return defined $self->{_param} ? $self->{_param}->param : ();
}

sub slurp {
    my ($self) = @_;

    my $fh = $self->fh;

    return if !defined $fh;

    binmode $fh;

    local $/;

    return <$fh>;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::Upload - uploaded file

=head1 DESCRIPTION

An instance is created for each uploaded file.

You will normally get an object of one of the following classes, which inherit
from L<HTML::FormFu::Upload>:

=over

=item L<HTML::FormFu::QueryType::CGI>

=item L<HTML::FormFu::QueryType::Catalyst>

=item L<HTML::FormFu::QueryType::CGI::Simple>

=back

=head1 METHODS

=head2 parent

Returns the L<field|HTML::FormFu::Role::Element::Field> object that the upload
object is associated with.

=head2 form

Returns the L<HTML::FormFu> object that the upload object's field is attached 
to.

=head2 populate

See L<HTML::FormFu/populate> for details.

=head1 SEE ALSO

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
