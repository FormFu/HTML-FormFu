package HTML::FormFu::Filter::CompoundJoin;

use strict;
use base 'HTML::FormFu::Filter';

__PACKAGE__->mk_accessors(qw/ join field_order /);

sub filter {
    my ( $self, $value ) = @_;

    return unless defined $value && $value ne "";
    
    my $join = $self->join;
    $join = ' ' if !defined $join;
    
    my ( $multi, @fields ) = @{ $self->parent->get_fields };
    
    if ( my $order = $self->field_order ) {
        my @new_order;
        
FIELD:  for my $i ( @$order ) {
            for my $field ( @fields ) {
                if ( $field->name eq $i ) {
                    push @new_order, $field;
                    next FIELD;
                }
            }
        }
        
        @fields = @new_order;
    }
    
    my @names = map { $_->name } @fields;
    
    $value = join $join, map { defined $_ ? $_ : '' } @{$value}{@names};
    
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

Arguments: \@order

If the submitted parts should be joined in an order different that that of the 
order of the fields, you must provide an arrayref containing the names, in the 
order they should be joined.

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
