package HTML::FormFu::Element::_MultiSelect;

use strict;
use base 'HTML::FormFu::Element::_MultiElement', 'HTML::FormFu::Element::Select';
use Class::C3;
use Carp qw( croak );

sub nested_names {
    my ($self) = @_;

    croak 'cannot set nested_names' if @_ > 1;

    if ( defined $self->name ) {
        my @names;

        # ignore immediate parent
        my $parent = $self->parent;

        while ( defined ( $parent = $parent->parent ) ) {

            if ( $parent->can('is_field') && $parent->is_field ) {
                push @names, $parent->name
                    if defined $parent->name;
            }
            else {
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

    while ( defined ( $parent = $parent->parent ) ) {

        return $parent->nested_name if defined $parent->nested_name;
    }
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::_MultiSelect

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
