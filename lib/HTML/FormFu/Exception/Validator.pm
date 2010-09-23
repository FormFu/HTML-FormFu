package HTML::FormFu::Exception::Validator;


use Moose;
extends 'HTML::FormFu::Exception::Input';

sub stage {
    return 'validator';
}

sub validator {
    return shift->processor(@_);
}

1;
