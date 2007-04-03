package HTML::FormFu::Exception::Validator;

use base 'HTML::FormFu::Exception::Input';

sub stage {
    return 'validator';
}

sub validator {
    return shift->processor(@_);
}

1;
