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
    
    if ( defined( my $order = $self->field_order ) ) {
        die "not yet implemented";
    }
    else {
        my @parts = split $split, $value;
        
        for my $i ( 0 .. $#fields ) {
            # if there are more parts than fields, join the extra ones
            # to make the final field's value
            
            if ( $i == $#fields ) {
                my $default = join $join, @parts[ $i .. $#parts ];
                
                $fields[$i]->default($default);
            }
            else {
                $fields[$i]->default( $parts[$i] );
            }
        }
    }
    
    return;
}


1;

__END__

=head1 NAME

HTML::FormFu::Deflator::CompoundSplit - CompoundSplit deflator

=head1 SYNOPSIS

=head1 DESCRIPTION

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
