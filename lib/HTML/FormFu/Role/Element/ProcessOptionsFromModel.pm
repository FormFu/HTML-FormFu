package HTML::FormFu::Role::Element::ProcessOptionsFromModel;
use Moose::Role;

sub _process_options_from_model {
    my ($self) = @_;

    my $args = $self->model_config;

    return if !$args || !keys %$args;

    return if @{ $self->options };

    # don't run if {options_from_model} is set and is 0

    my $option_flag
        = exists $args->{options_from_model}
        ? $args->{options_from_model}
        : 1;

    return if !$option_flag;

    $self->options(
        [ $self->form->model->options_from_model( $self, $args ) ] );

    return;
}


1;

