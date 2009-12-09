package HTML::FormFu::Exception;

use strict;
use Scalar::Util qw( reftype );
use Carp qw( croak );

use HTML::FormFu::Attribute qw( mk_item_accessors mk_accessors );
use HTML::FormFu::ObjectUtil qw( form parent get_parent populate );

sub new {
    my $class = shift;
    my %attrs;
    
    if (@_) {
        croak "attributes argument must be a hashref"
            if reftype( $_[0] ) ne 'HASH';
        
        %attrs = %{ $_[0] };
    }

    my $self = bless {}, $class;

    $self->populate( \%attrs );

    return $self;
}

1;
