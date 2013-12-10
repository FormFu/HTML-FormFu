package HTML::FormFu::Exception::Constraint;

use Moose;
extends 'HTML::FormFu::Exception::Input';

sub stage {
    return 'constraint';
}

sub constraint {
    return shift->processor(@_);
}

around render_data_non_recursive => sub {
    my ( $orig, $self, $args ) = @_;

    my $render = $self->$orig( {
            stage      => $self->stage,
            constraint => $self->constraint,
            $args ? %$args : (),
        });

    return $render;
};

__PACKAGE__->meta->make_immutable;

1;
