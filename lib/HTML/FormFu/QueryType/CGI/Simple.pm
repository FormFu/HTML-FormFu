package HTML::FormFu::QueryType::CGI::Simple;

use strict;
use warnings;
use base 'Class::Accessor::Chained::Fast';

use Carp qw( croak );

__PACKAGE__->mk_accessors(qw/ query name /);

sub headers {
    my ($self) = @_;

    my @filenames = $self->query->param( $self->name );
    my @headers;

    if (@filenames) {
        for my $file (@filenames) {
            my %header = (
                'Content-Type'   => $self->query->upload_info( $file, 'mime' ),
                'Content-Length' => $self->query->upload_info( $file, 'size' ),
            );
            push @headers, %header;
        }
        return \@headers;
    }

    return;
}

1;
