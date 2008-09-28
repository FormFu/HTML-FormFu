package HTML::FormFu::Inflator::DateTime;

use strict;
use base 'HTML::FormFu::Inflator';
use Class::C3;

use HTML::FormFu::Constants qw( $EMPTY_STR );
use DateTime::Format::Builder;
use DateTime::Format::Strptime;

__PACKAGE__->mk_item_accessors( qw( strptime time_zone _builder ) );

sub new {
    my $self = shift->next::method(@_);

    $self->_builder( DateTime::Format::Builder->new );

    return $self;
}

sub parser {
    my ( $self, $arg ) = @_;

    if ( exists $arg->{regex} && !ref $arg->{regex} ) {
        $arg->{regex} = qr/$arg->{regex}/;
    }

    $self->_builder->parser($arg);

    return $self;
}

sub inflator {
    my ( $self, $value ) = @_;

    return if !defined $value || $value eq $EMPTY_STR;

    my $dt = $self->_builder->parse_datetime($value);

    if ( defined $self->time_zone ) {
        $dt->set_time_zone( $self->time_zone );
    }

    if ( defined $self->strptime ) {
        my $strptime = $self->strptime;
        my %args;

        eval { %args = %$strptime };
        if ($@) {
            %args = ( pattern => $strptime );
        }

        # Make strptime format the date with the specified time_zone,
        # this is most likely what the user wants
        if ( defined $self->time_zone ) {
            $args{time_zone} = $self->time_zone;
        }

        my $formatter = DateTime::Format::Strptime->new(%args);

        $dt->set_formatter($formatter);
    }

    return $dt;
}

sub clone {
    my $self = shift;

    my $clone = $self->next::method(@_);

    $clone->_builder( $self->_builder->clone );

    return $clone;
}

1;

__END__

=head1 NAME

HTML::FormFu::Inflator::DateTime - DateTime inflator

=head1 SYNOPSIS

    ---
    elements:
      - type: Text
        name: start_date
        inflators:
          - type: DateTime
            parser: 
              strptime: '%d-%m-%Y'
            strptime:
              pattern: '%d-%b-%Y'
              locale: de
      
      - type: Text
        name: end_time
        inflators:
          - type: DateTime
            time_zone: Europe/Rome
            parser:
              regex: '^ (\d{2}) - (\d{2}) - (\d{4}) $'
              params: [day, month, year]
            strptime: '%d-%m-%Y'

An example of using the same parser declaration for both a DateTime
constraint and a DateTime inflator, using YAML references:

    ---
    elements:
      - type: Text
        name: date
        constraints:
          - type: DateTime
            parser: &PARSER
              strptime: '%d-%m-%Y'
        inflators:
          - type: DateTime
            parser: *PARSER

=head1 DESCRIPTION

Inflate dates into L<DateTime> objects.

For a corresponding deflator, see L<HTML::FormFu::Deflator::Strftime>.

=head1 METHODS

=head2 parser

Arguments: \%args

Required. Define the expected input string, so L<DateTime::Format::Builder> 
knows how to inflate it into a L<DateTime> object.

Accepts arguments to be passed to L<DateTime::Format::Builder/parser>.

=head2 strptime

Arguments: \%args

Arguments: $string

Optional. Define the format that should be used if the L<DateTime> object is 
stringified.

=head2 time_zone

Arguments: $string

Optional. You can pass along a time_zone in which the DateTime will be
created. This is useful if the string to parse does not contain time zone
information and you want the DateTime to be in a specific zone instead
of the floating one (which is likely).

Accepts a hashref of arguments to be passed to 
L<DateTime::Format::Strptime/new>. Alternatively, accepts a single string 
argument, suitable for passing to 
C<< DateTime::Format::Strptime->new( pattern => $string ) >>.

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
