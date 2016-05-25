package HTML::FormFu::Exception;

use strict;
# VERSION

use Moose;

with 'HTML::FormFu::Role::Populate';

use HTML::FormFu::ObjectUtil qw( form parent );

sub BUILD { }

sub render_data {
    my $self = shift;

    my $render = $self->render_data_non_recursive( { @_ ? %{ $_[0] } : () } );

    return $render;
}

sub render_data_non_recursive {
    my ( $self, $args ) = @_;

    my %render = (
        parent => $self->parent,
        form   => $self->form,
        $args ? %$args : (),
    );

    return \%render;
}

__PACKAGE__->meta->make_immutable;

1;
