package HTML::FormFu::Deflator::CompoundSplit;

use strict;
use base 'HTML::FormFu::Deflator';

__PACKAGE__->mk_accessors(qw/ split join field_order /);

sub deflator {
    my ( $self, $value ) = @_;

    return unless defined $value && $value ne "";
    
    my ( $multi, @fields ) = @{ $self->parent->get_fields };
    
    my $split = $self->split;
    $split = qr/ +/, if !defined $split;
    
    my $join = $self->join;
    $join = ' ' if !defined $join;
    
    my @parts = CORE::split $split, $value;
    
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
    
    my %value;

    for my $i ( 0 .. $#fields ) {
        # if there are more parts than fields, join the extra ones
        # to make the final field's value
            
        if ( $i == $#fields ) {
            my $default = CORE::join $join, @parts[ $i .. $#parts ];
            
            $fields[$i]->default( $default );
            
            $value{ $fields[$i]->name } = $default;
        }
        else {
            $fields[$i]->default( $parts[$i] );
            
            $value{ $fields[$i]->name } = $parts[$i];
        }
    }
    
    return \%value;
}


1;

__END__

=head1 NAME

HTML::FormFu::Deflator::CompoundSplit - CompoundSplit deflator

=head1 SYNOPSIS

    ---
    element:
      - type: Multi
        name: address
        
        elements:
          - name: number
          - name: street
        
        deflator:
          - type: CompoundSplit

    # set the default
    
    $form->get_field('address')->default( $address );

=head1 DESCRIPTION

Deflator to allow you to set several field's values at once.

For use with a L<HTML::FormFu::Element::Multi> group of fields.

A L<default|HTML::FormFu::Element::_Field/default> value passed to the 
L<Multi|HTML::FormFu::Element::Multi> field will be split according to the 
L</split> setting, and it's resulting parts passed to it's child elements.

=head1 METHODS

=head2 split

Arguments: $regex

Default Value: C<qr/ +/>

Regex used to split the default value. Defaults to a regex matching 1 or more 
space characters.

=head2 join

Arguments: $string

Default Value: C<' '>

If spliting the value results in more parts than there are fields, any extra 
parts are joined again to form the value for the last field. The value of 
L</join> is used to join these values.

Defaults to a single space.

For example, if the Multi element contains fields C<number> and C<name>, 
and is given the value C<10 Downing Street>; when split this results in 3 
parts: C<10>, C<Downing> and C<Street>. In this case, the 1st part, C<10> is 
assigned to the first field, and the 2nd and 3rd parts are re-joined with a 
space to give the single value C<Downing Street>, which is assigned to the 
2nd field.

=head2 field_order

Arguments: \@order

If the parts from the split value should be assigned to the fields in a 
different order, you must provide an arrayref containing the names, in the 
order they should be assigned to.

    ---
    element:
      - type: Multi
        name: address
        
        elements:
          - name: street
          - name: number
        
        deflator:
          - type: CompoundSplit
            field_order:
              - number
              - street

=head1 AUTHOR

Carl Franks

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
