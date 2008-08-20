package HTML::FormFu::Element::_DateSelect;

use strict;
use base 'HTML::FormFu::Element::Select';
use Carp qw/ croak /;

sub nested_names {
    my $self = shift;

    croak 'cannot set nested_names' if @_;

    if ( defined $self->name ) {
        my @names;

        # ignore immediate parent
        my $parent = $self->parent;

        while ( defined $parent->parent ) {
            $parent = $parent->parent;

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
    my $self = shift;

    croak 'cannot set nested_base' if @_;

    # ignore immediate parent
    my $parent = $self->parent;

    while ( defined $parent->parent ) {
        $parent = $parent->parent;

        return $parent->nested_name if defined $parent->nested_name;
    }
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::_DateSelect

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
