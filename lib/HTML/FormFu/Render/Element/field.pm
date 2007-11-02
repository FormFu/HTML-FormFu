package HTML::FormFu::Render::Element::field;

use strict;
use base 'HTML::FormFu::Render::Element';

use HTML::FormFu::Attribute qw/ mk_accessors /;

__PACKAGE__->mk_accessors(qw/ nested_name /);

sub label_tag {
    my ($self) = @_;

    return $self->output( $self->{label_filename} );
}

sub field_tag {
    my ($self) = @_;

    return $self->output( $self->{field_filename} );
}

1;
