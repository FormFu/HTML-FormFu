package HTML::FormFu::Exception::Inflator;

use strict;

use base 'HTML::FormFu::Exception::Input';

sub stage {
    return 'inflator';
}

sub inflator {
    return shift->processor(@_);
}

1;
