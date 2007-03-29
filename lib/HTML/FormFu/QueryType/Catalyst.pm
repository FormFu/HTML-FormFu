package HTML::FormFu::QueryType::Catalyst;

use strict;
use warnings;
use base 'HTML::FormFu::QueryType::CGI';

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
        my $param = $class->new({
            _param => $upload,
            parent => $form,
            });
        
        push @new, $param;
    }
    
    return if !@new;
    
    return @new == 1 ? $new[0] : \@new;
}

sub headers {
    my ($self) = @_;

    my $http = $self->_param->headers;
    my %header;
    
    for my $key ( $http->header_field_names ) {
        $header{$key} = $http->header($key);
    }
    
    return \%header;
}

sub filename {
    my ($self) = @_;
    
    return $self->_param->filename;
}

sub fh {
    my ($self) = @_;
    
    return $self->_param->fh;
}

sub slurp {
    my ($self) = @_;
    
    return $self->_param->slurp;
}

1;
