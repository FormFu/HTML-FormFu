package HTML::FormFu::Deflator::CompoundDateTime;

use strict;
use base 'HTML::FormFu::Deflator';

use DateTime;
use Carp qw( croak );

__PACKAGE__->mk_accessors(qw/ field_order /);

my @known_fields = qw( year month day hour minute second nanosecond time_zone );

sub deflator {
    my ( $self, $value ) = @_;

    return unless defined $value && $value ne "";
    
    # do we have a DateTime object?
    
    eval {
        $value->$_ for @known_fields
    };
    
    return $value if $@;
    
    my ( $multi, @fields ) = @{ $self->parent->get_fields };
    
    if ( defined( my $order = $self->field_order ) ) {
        for my $order (@$order) {
            croak "unknown DateTime field_order name"
                unless grep { $order eq $_ } @known_fields;
            
            my $field = shift @fields;
            
            $field->default( $value->$order );
        }
    }
    else {
        for my $field (@fields) {
            my $name = $field->name;
            
            croak "unknown DateTime field name"
                unless grep { $name eq $_ } @known_fields;
            
            $field->default( $value->$name );
        }
    }
    
    return;
}


1;

__END__

=head1 NAME

HTML::FormFu::Deflator::CompoundDateTime - CompoundDateTime deflator

=head1 SYNOPSIS

    ---
    element:
      - type: Multi
        name: date
        
        elements:
          - name: day
          - name: month
          - name: year
        
        deflator:
          - type: CompoundDateTime

    # set the default
    
    $form->get_field('date')->default( $datetime );

=head1 DESCRIPTION

For use with a L<HTML::FormFu::Element::Multi> group of fields.

Sets the default values of several fields from a single L<DateTime> value.

By default, expects the field names to be any of the following:

=over

=item year

=item month

=item day

=item hour

=item minute

=item second

=item nanosecond

=item time_zone

=back

=head1 METHODS

=head2 field_order

Arguments: \@order

If your field names doesn't follow the convention listed above, you must 
provide an arrayref containing the above names, in the order they correspond 
with your own fields.

    ---
    element:
      - type: Multi
        name: date
        
        elements:
          - name: m
          - name: d
          - name: y
        
        deflator:
          - type: CompoundDateTime
            field_order:
              - month
              - day
              - year

=head1 AUTHOR

Carl Franks

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
