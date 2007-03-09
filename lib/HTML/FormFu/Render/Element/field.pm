package HTML::FormFu::Render::Element::field;

use strict;
use warnings;
use base 'HTML::FormFu::Render::Element';

sub label_tag {
    my ($self) = @_;

    return $self->output( $self->{label_filename} );
}

sub field_tag {
    my ($self) = @_;

    return $self->output( $self->{field_filename} );
}

1;
