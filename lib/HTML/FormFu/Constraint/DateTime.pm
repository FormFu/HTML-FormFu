package HTML::FormFu::Constraint::DateTime;

use strict;
use base 'HTML::FormFu::Constraint';
use Class::C3;

use DateTime::Format::Builder;
use DateTime::Format::Strptime;

__PACKAGE__->mk_item_accessors( qw( _builder ) );

sub new {
    my $self = shift->next::method(@_);

    $self->_builder( DateTime::Format::Builder->new );

    return $self;
}

sub parser {
    my $self = shift;

    $self->_builder->parser(@_);

    return $self;
}

sub constrain_value {
    my ( $self, $value ) = @_;

    return 1 if !defined $value || $value eq '';

    my $dt = $self->_builder->parse_datetime($value);

    return 1;
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
            parser:
              regex: '^ (\d{2}) - (\d{2}) - (\d{4}) $'
              params: [day, month, year]
            strptime: '%d-%m-%Y'

=head1 DESCRIPTION

Inflate dates into L<DateTime> objects.

=head1 METHODS

=head2 parser

Arguments: \%args

Required. Define the expected input string, so L<DataTime::Format::Builder> 
knows how to inflate it into a L<DateTime> object.

Accepts arguments to be passed to L<DateTime::Format::Builder/parser>.

=head2 strptime

Arguments: \%args

Arguments: $string

Optional. Define the format that should be used if the L<DateTime> object is 
stringified.

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
