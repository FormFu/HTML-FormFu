package HTML::FormFu::Filter::CompoundJoin;

use strict;
use base 'HTML::FormFu::Filter::_Compound';

use HTML::FormFu::Constants qw( $EMPTY_STR $SPACE );

__PACKAGE__->mk_item_accessors(qw( join ));

sub filter {
    my ( $self, $value ) = @_;

    return if !defined $value || $value eq $EMPTY_STR;

    my $join
        = defined $self->join
        ? $self->join
        : $SPACE;

    my @values = $self->_get_values($value);

    @values = grep { $_ ne '' } @values;

    $value = join $join, @values;

    return $value;
}

1;

__END__

=head1 NAME

HTML::FormFu::Filter::CompoundJoin - CompoundJoin filter

=head1 SYNOPSIS

    ---
    element:
      - type: Multi
        name: address
        
        elements:
          - name: number
          - name: street
        
        filter:
          - type: CompoundJoin

    # get the compound-value
    
    my $address = $form->param_value('address');

=head1 DESCRIPTION

For use with a L<HTML::FormFu::Element::Multi> group of fields.

Joins the input from several fields into a single value.

=head1 METHODS

=head2 join

Arguments: $string

Default Value: C<' '>

String used to join the individually submitted parts. Defaults to a single 
space.

=head2 field_order

Inherited. See L<HTML::FormFu::Filter::_Compound/field_order> for details.

    ---
    element:
      - type: Multi
        name: address
        
        elements:
          - name: street
          - name: number
        
        filter:
          - type: CompoundJoin
            field_order:
              - number
              - street

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
