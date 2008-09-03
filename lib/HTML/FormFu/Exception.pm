package HTML::FormFu::Exception;

use strict;
use Carp qw( croak );

use HTML::FormFu::Attribute qw( mk_item_accessors mk_accessors );
use HTML::FormFu::ObjectUtil qw( form parent populate );

sub new {
    my $class = shift;

    my %attrs;
    eval { %attrs = %{ $_[0] } if @_ };
    croak "attributes argument must be a hashref" if $@;

    my $self = bless {}, $class;

    $self->populate( \%attrs );

    return $self;
}

1;
