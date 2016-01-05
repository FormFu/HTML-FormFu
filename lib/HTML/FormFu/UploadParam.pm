package HTML::FormFu::UploadParam;

use Moose;
use MooseX::Attribute::FormFuChained;

use Carp qw( croak );

use File::Temp qw( tempfile );
use Scalar::Util qw( weaken );
use Storable qw( nfreeze thaw );

has param => ( is => 'rw', traits => ['FormFuChained'], required => 1 );
has filename => ( is => 'rw', traits => ['FormFuChained'] );

sub form {
    my $self = shift;

    if (@_) {
        $self->{form} = shift;

        weaken( $self->{form} );
    }

    return $self->{form};
}

sub STORABLE_freeze {
    my ( $self, $cloning ) = @_;

    return if $cloning;

    my $fh
        = $self->{param}->can('fh')
        ? $self->{param}->fh
        : $self->{param};

    seek $fh, 0, 0;

    local $/ = undef;
    my $data = <$fh>;

    if ( defined( my $dir = $self->form->tmp_upload_dir ) ) {
        my ( $fh, $filename ) = tempfile( DIR => $dir, UNLINK => 0 );

        print $fh $data;

        close $fh;

        return nfreeze( { filename => $filename } );
    }
    else {
        return nfreeze( { param => $data } );
    }
}

sub STORABLE_thaw {
    my ( $self, $cloning, $serialized ) = @_;

    return if $cloning;

    my $data = thaw($serialized);

    my $filename = $data->{filename};

    if ($filename) {
        open my $fh, '<', $filename
            or croak "could not open file in tmp dir: '$filename'";

        $self->{param}    = $fh;
        $self->{filename} = $filename;
    }
    else {
        my ($fh) = tempfile();

        print $fh $data->{param};

        seek $fh, 0, 0;

        $self->{param} = $fh;
    }

    return;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::UploadParam - accessor class

=head1 DESCRIPTION

=head1 SEE ALSO

L<HTML::FormFu>, L<HTML::FormFu::Upload>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
