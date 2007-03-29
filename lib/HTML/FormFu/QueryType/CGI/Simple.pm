package HTML::FormFu::QueryType::CGI::Simple;

use strict;
use warnings;
use base 'HTML::FormFu::QueryType::CGI';

__PACKAGE__->mk_accessors(qw/ _filename /);

sub parse_uploads {
    my ( $class, $form, $name ) = @_;
    
    my @params = $form->query->param($name);
    my @new;
    
    for my $param (@params) {
        if ( my $file = $form->query->upload($param) ) {
            $param = $class->new({
                _param    => $file,
                _filename => $param,
                parent    => $form,
                });
        }
        push @new, $param;
    }
    
    return if !@new;
    
    return @new == 1 ? $new[0] : \@new;
}

sub headers {
    my ($self) = @_;

    my %header = (
        'Content-Type'   => $self->form->query->upload_info( $self->_filename, 'mime' ),
        'Content-Length' => $self->form->query->upload_info( $self->_filename, 'size' ),
    );

    return \%header;
}

sub filename {
    my ($self) = @_;
    
    return $self->_filename;
}

sub fh {
    my ($self) = @_;
    
    return $self->form->query->upload( $self->_filename );
}

1;
