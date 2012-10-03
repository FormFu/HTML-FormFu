package HTML::FormFu::Exception::Constraint;

use Moose;
extends 'HTML::FormFu::Exception::Input';

sub stage {
    return 'constraint';
}

sub constraint {
    return shift->processor(@_);
}

__PACKAGE__->meta->make_immutable;

1;
