package HTML::FormFu::Render::Element;

use strict;
use warnings;
use base 'HTML::FormFu::Render::base';

use Carp qw/ croak /;

__PACKAGE__->mk_attr_accessors(qw/ id /);

__PACKAGE__->mk_accessors(qw/ name type multi_filename is_field /);

sub multi {
    my $self = shift;

    my $file =
        defined $self->multi_filename
        ? $self->multi_filename
        : $self->filename;

    return $self->output( $file, @_ );
}

sub as {
    my $self = shift;
    
    if ( $self->parent->can('as') ) {
        return $self->parent->as(@_);
    }
    
    croak "element doesn't implement 'as'";
}

sub elements { [] }

sub element { }

sub fields { [] }

sub field { }

1;
