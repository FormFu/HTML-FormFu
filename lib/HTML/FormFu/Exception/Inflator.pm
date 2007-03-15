package HTML::FormFu::Exception::Inflator;

use base 'HTML::FormFu::Exception::Input';

__PACKAGE__->mk_accessors(qw/ inflator /);

sub stage {
    return 'inflator';
}

sub type {
    my $self = shift;
    
    return $self->inflator->inflator_type;
}

1;
