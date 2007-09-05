package HTML::FormFu::Upload;

use strict;
use Carp qw( croak );

use HTML::FormFu::Attribute qw( mk_accessors );
use HTML::FormFu::ObjectUtil qw( form parent populate );

__PACKAGE__->mk_accessors(qw/ _param /);

sub new {
    my $class = shift;

    my %attrs;
    eval { %attrs = %{ $_[0] } if @_ };
    croak "attributes argument must be a hashref" if $@;

    my $self = bless \%attrs, $class;
    
    $self->populate( \%attrs );
    
    return $self;
}

1;
