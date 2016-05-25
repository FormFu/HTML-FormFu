package HTML::FormFu::Exception::Validator;

use strict;
# VERSION

use Moose;
extends 'HTML::FormFu::Exception::Input';

sub stage {
    return 'validator';
}

sub validator {
    return shift->processor(@_);
}

around render_data_non_recursive => sub {
    my ( $orig, $self, $args ) = @_;

    my $render = $self->$orig( {
            stage     => $self->stage,
            validator => $self->validator,
            $args ? %$args : (),
        });

    return $render;
};

__PACKAGE__->meta->make_immutable;

1;
