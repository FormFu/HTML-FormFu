package HTML::FormFu::Render::Element::multi;

use strict;
use base 'HTML::FormFu::Render::Element::block';

sub label_tag {
    my ($self) = @_;

    return $self->output( $self->{label_filename} );
}

sub field_tag {
    my ($self) = @_;

    return $self->output( $self->{field_filename} );
}

1;
