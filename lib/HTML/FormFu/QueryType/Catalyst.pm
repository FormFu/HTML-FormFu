package HTML::FormFu::QueryType::Catalyst;

use strict;
use warnings;
use base 'HTML::FormFu::QueryType::CGI';

sub parse_uploads {
    my ( $class, $form, $field ) = @_;
    
    my @filenames = $form->query->upload( $field->name );
    my @objects;
    
    for my $file (@filenames) {
        my $obj = $class->new({
            parent => $field,
            _file  => $file,
            });
        
        push @objects, $obj;
    }
    
    return \@objects;
}

sub headers {
    my ($self) = @_;

    my $http = $self->_file->headers;
    my %header;
    
    for my $key ( $http->header_field_names ) {
        $header{$key} = $http->header($key);
    }
    
    return \%header;
}

sub fh {
    my ($self) = @_;
    
    return $self->_file->fh;
}

sub slurp {
    my ($self) = @_;
    
    return $self->_file->slurp;
}

1;
