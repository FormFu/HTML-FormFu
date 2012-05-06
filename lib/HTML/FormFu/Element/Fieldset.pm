package HTML::FormFu::Element::Fieldset;

use Moose;
extends 'HTML::FormFu::Element::Block';

__PACKAGE__->mk_output_accessors(qw( legend ));

after BUILD => sub {
    my $self = shift;

    $self->tag('fieldset');

    return;
};

sub render_data_non_recursive {
    my ( $self, $args ) = @_;

    my $render = $self->SUPER::render_data_non_recursive( {
            legend => $self->legend,
            $args ? %$args : (),
        } );

    return $render;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::Element::Fieldset - Fieldset element

=head1 SYNOPSIS

    my $fs = $form->element( Fieldset => 'address' );

=head1 DESCRIPTION

Fieldset element.

=head1 METHODS

=head2 legend

If L</legend> is set, it is used as the fieldset's legend

=head2 legend_loc

Arguments: $localization_key

To set the legend to a localized string, set L</legend_loc> to a key in 
your L10N file instead of using L</legend>.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::Block>, 
L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
