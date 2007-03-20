package HTML::FormFu::Exception::Transformer;

use base 'HTML::FormFu::Exception::Input';

__PACKAGE__->mk_accessors(qw/ transformer /);

sub stage {
    return 'transformer';
}

sub type {
    my $self = shift;
    
    return $self->transformer->transformer_type;
}

1;
