package HTML::FormFu::Exception::Constraint;

use base 'HTML::FormFu::Exception::Input';

__PACKAGE__->mk_accessors(qw/ constraint /);

sub stage {
    return 'constraint';
}

sub type {
    my $self = shift;
    
    return $self->constraint->type;
}

1;
