package HTML::FormFu::Role::Element::MultiElement;

use Moose::Role;

use Carp qw( croak );

sub nested_names {
    my ($self) = @_;

    croak 'cannot set nested_names' if @_ > 1;

    if ( defined $self->name ) {
        my @names;

        # ignore immediate parent
        my $parent = $self->parent;

        while ( defined( $parent = $parent->parent ) ) {

            if ( $parent->can('is_field') && $parent->is_field ) {

                # handling Field
                push @names, $parent->name
                    if defined $parent->name;
            }
            elsif ( $parent->can('is_repeatable') && $parent->is_repeatable ) {

                # handling Repeatable
                # ignore Repeatables nested_name attribute as it is provided
                # by the childrens Block elements
            }
            else {

                # handling 'not Field' and 'not Repeatable'
                push @names, $parent->nested_name
                    if defined $parent->nested_name;
            }
        }

        if (@names) {
            return reverse(@names), $self->name;
        }
    }

    return ( $self->name );
}

sub nested_base {
    my ($self) = @_;

    croak 'cannot set nested_base' if @_ > 1;

    # ignore immediate parent
    my $parent = $self->parent;

    while ( defined( $parent = $parent->parent ) ) {

        return $parent->nested_name if defined $parent->nested_name;
    }
}

1;
