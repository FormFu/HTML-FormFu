package HTML::FormFu::Exception::Inflator;

use Moose;
extends 'HTML::FormFu::Exception::Input';

sub stage {
    return 'inflator';
}

sub inflator {
    return shift->processor(@_);
}

__PACKAGE__->meta->make_immutable;

1;
