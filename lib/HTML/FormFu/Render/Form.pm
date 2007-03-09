package HTML::FormFu::Render::Form;

use strict;
use warnings;
use base 'HTML::FormFu::Render::base';

use HTML::FormFu::Util qw/ require_class /;
use Carp qw/ croak /;

__PACKAGE__->mk_attr_accessors(qw/ id action enctype method /);

sub start_form {
    my ($self) = @_;

    return $self->output('start_form');
}

sub end_form {
    my ($self) = @_;

    return $self->output('end_form');
}

1;
