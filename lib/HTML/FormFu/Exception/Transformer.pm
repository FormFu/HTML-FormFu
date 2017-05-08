use strict;
package HTML::FormFu::Exception::Transformer;


use Moose;
extends 'HTML::FormFu::Exception::Input';

sub stage {
    return 'transformer';
}

sub transformer {
    return shift->processor(@_);
}

around render_data_non_recursive => sub {
    my ( $orig, $self, $args ) = @_;

    my $render = $self->$orig( {
            stage       => $self->stage,
            transformer => $self->transformer,
            $args ? %$args : (),
        });

    return $render;
};

__PACKAGE__->meta->make_immutable;

1;
