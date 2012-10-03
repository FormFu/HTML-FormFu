package HTML::FormFu::Exception::Validator;

use Moose;
extends 'HTML::FormFu::Exception::Input';

sub stage {
    return 'validator';
}

sub validator {
    return shift->processor(@_);
}

__PACKAGE__->meta->make_immutable;

1;
