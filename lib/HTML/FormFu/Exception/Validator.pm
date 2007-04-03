package HTML::FormFu::Exception::Validator;

use base 'HTML::FormFu::Exception::Input';

__PACKAGE__->mk_accessors(qw/ validator /);

sub stage {
    return 'validator';
}

sub type {
    my $self = shift;
    
    return $self->validator->type;
}

1;
