use strict;

package HTML::FormFu::Exception::Inflator;

use Moose;
extends 'HTML::FormFu::Exception::Input';

sub stage {
    return 'inflator';
}

sub inflator {
    return shift->processor(@_);
}

around render_data_non_recursive => sub {
    my ( $orig, $self, $args ) = @_;

    my $render = $self->$orig(
        {   stage    => $self->stage,
            inflator => $self->inflator,
            $args ? %$args : (),
        } );

    return $render;
};

__PACKAGE__->meta->make_immutable;

1;
