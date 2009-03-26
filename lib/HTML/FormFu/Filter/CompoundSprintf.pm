package HTML::FormFu::Filter::CompoundSprintf;

use strict;
use base 'HTML::FormFu::Filter::_Compound';

use HTML::FormFu::Constants qw( $EMPTY_STR );
use Carp qw( croak );

__PACKAGE__->mk_item_accessors(qw( sprintf ));

sub filter {
    my ( $self, $value ) = @_;

    return if !defined $value || $value eq $EMPTY_STR;

    my $sprintf = $self->sprintf;

    croak 'sprintf pattern required' if !defined $sprintf;

    my @values = $self->_get_values($value);

    $value = CORE::sprintf( $sprintf, @values );

    return $value;
}

1;

__END__

=head1 NAME

HTML::FormFu::Filter::CompoundSprintf - CompoundSprintf filter

=head1 SYNOPSIS

    ---
    element:
      - type: Multi
        name: date
        
        elements:
          - name: day
          - name: month
          - name: year
        
        filter:
          - type: CompoundSprintf
            sprintf: '%02d-%02d-%04d'

    # get the compound-value
    
    my $date = $form->param_value('date');

=head1 DESCRIPTION

For use with a L<HTML::FormFu::Element::Multi> group of fields.

Uses a sprintf pattern to join the input from several fields into a single
value.

=head1 METHODS

=head2 sprintf

Arguments: $string

C<sprintf> pattern used to join the individually submitted parts.
The pattern is passed to the perl-core C<sprintf> function.

=head2 field_order

Inherited. See L<HTML::FormFu::Filter::_Compound/field_order> for details.

    ---
    element:
      - type: Multi
        name: date
        
        elements:
          - name: month
          - name: day
          - name year
        
        filter:
          - type: CompoundSprintf
            field_order:
              - day
              - month
              - year

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
