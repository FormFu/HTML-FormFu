package HTML::FormFu::QueryType::CGI;

use strict;
use warnings;
use base 'HTML::FormFu::Upload';

sub parse_uploads {
    my ( $class, $form, $name ) = @_;
    
    my @params = $form->query->param($name);
    my @new;
    
    for my $param (@params) {
        if ( ref $param ) {
            $param = $class->new({
                _param => $param,
                parent => $form,
                });
        }
        
        push @new, $param;
    }
    
    return if !@new;
    
    return @new == 1 ? $new[0] : \@new;
}

sub headers {
    my ($self) = @_;

    return $self->form->query->uploadInfo( $self->_param );
}

sub filename {
    my ($self) = @_;
    
    return sprintf "%s", $self->_param;
}

sub fh {
    my ($self) = @_;
    
    return $self->_param;
}

sub slurp {
    my ($self) = @_;
    
    my $fh = $self->fh;
    
    binmode $fh;
    
    local $/;
    
    return <$fh>;
}

1;
