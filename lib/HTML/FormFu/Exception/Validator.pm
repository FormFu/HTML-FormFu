package HTML::FormFu::Exception::Validator;

use strict;

use base 'HTML::FormFu::Exception::Input';

sub stage {
    return 'validator';
}

sub validator {
    return shift->processor(@_);
}

1;
