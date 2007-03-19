package HTML::FormFu::QueryType::CGI;

use strict;
use warnings;
use base 'Class::Accessor::Chained::Fast';

use HTML::FormFu::ObjectUtil qw/ form /;

__PACKAGE__->mk_accessors(qw/ _file parent /);

sub parse_uploads {
    my ( $class, $form, $field ) = @_;
    
    my @filenames = $form->query->param( $field->name );
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

    return $self->form->query->uploadInfo( $self->_file );
}

sub fh {
    my ($self) = @_;
    
    return $self->_file;
}

sub slurp {
    my ($self) = @_;
    
    my $fh = $self->fh;
    
    binmode $fh;
    
    local $/;
    
    return <$fh>;
}

1;
