package HTML::FormFu::Inflator::CompoundDateTime;

use strict;
use base 'HTML::FormFu::Inflator';
use Class::C3;

use HTML::FormFu::Constants qw( $EMPTY_STR );
use DateTime;
use DateTime::Format::Strptime;
use List::MoreUtils qw( none );
use Scalar::Util qw( reftype );
use Carp qw( croak );

__PACKAGE__->mk_item_accessors(qw( strptime ));

__PACKAGE__->mk_accessors(qw( field_order ));

my @known_fields = qw( year month day hour minute second nanosecond time_zone );

sub inflator {
    my ( $self, $value ) = @_;

    return if !defined $value || $value eq $EMPTY_STR;

    my ( $multi, @fields ) = @{ $self->parent->get_fields };
    my %input;

    if ( defined( my $order = $self->field_order ) ) {
        for my $order (@$order) {
            croak "unknown DateTime field_order name"
                if none { $order eq $_ } @known_fields;

            my $field = shift @fields;
            my $name  = $field->name;

            $input{$order} = $value->{$name};
        }
    }
    else {
        for my $name ( keys %$value ) {
            croak "unknown DateTime field name"
                if none { $name eq $_ } @known_fields;
        }

        %input = %$value;
    }

    my $dt;

    eval { $dt = DateTime->new(%input) };

    return $value if $@;

    if ( defined $self->strptime ) {
        my $strptime = $self->strptime;
        my %args;

        if ( ( reftype( $strptime ) || '' ) eq 'HASH' ) {
            %args = %$strptime;
        }
        else {
            %args = ( pattern => $strptime );
        }

        my $formatter = DateTime::Format::Strptime->new(%args);

        $dt->set_formatter($formatter);
    }

    return $dt;
}

1;

__END__

=head1 NAME

HTML::FormFu::Inflator::CompoundDateTime - CompoundDateTime inflator

=head1 SYNOPSIS

    ---
    element:
      - type: Multi
        name: date
        
        elements:
          - name: day
          - name: month
          - name: year
        
        inflator:
          - type: CompoundDateTime

    # get the submitted value as a DateTime object
    
    my $date = $form->param_value('date');

=head1 DESCRIPTION

For use with a L<HTML::FormFu::Element::Multi> group of fields.

Changes the input from several fields into a single L<DateTime> value.

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
        
        inflator:
          - type: CompoundDateTime
            field_order:
              - month
              - day
              - year

=head2 strptime

Arguments: \%args

Arguments: $string

Optional. Define the format that should be used if the L<DateTime> object is 
stringified.

Accepts a hashref of arguments to be passed to 
L<DateTime::Format::Strptime/new>. Alternatively, accepts a single string 
argument, suitable for passing to 
C<< DateTime::Format::Strptime->new( pattern => $string ) >>.

    ---
    inflator:
      - type: CompoundDateTime
        strptime:
          pattern: '%d-%b-%Y'
          locale: de

    ---
    inflator:
      - type: CompoundDateTime
        strptime: '%d-%m-%Y'

=head1 AUTHOR

Carl Franks

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
