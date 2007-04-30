package HTML::FormFu::Exception::Constraint;

use base 'HTML::FormFu::Exception::Input';

__PACKAGE__->mk_accessors(qw/ forced /);

sub stage {
    return 'constraint';
}

sub constraint {
    return shift->processor(@_);
}

1;
