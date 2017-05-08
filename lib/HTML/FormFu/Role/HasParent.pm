use strict;
package HTML::FormFu::Role::HasParent;


use Moose::Role;

sub BUILD {
    my ( $self, $args ) = @_;

    # Moose's new() only handles attributes - not methods

    if ( exists $args->{parent} ) {
        $self->parent( delete $args->{parent} );
    }

    return;
}

1;
