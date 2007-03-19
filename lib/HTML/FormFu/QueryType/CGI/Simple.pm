package HTML::FormFu::QueryType::CGI::Simple;

use strict;
use warnings;
use base 'HTML::FormFu::QueryType::CGI';

sub headers {
    my ($self) = @_;

    my %header = (
        'Content-Type'   => $self->form->query->upload_info( $self->_file, 'mime' ),
        'Content-Length' => $self->form->query->upload_info( $self->_file, 'size' ),
    );

    return \%header;
}

sub fh {
    my ($self) = @_;
    
    return $self->form->query->upload( $self->_file );
}

1;
