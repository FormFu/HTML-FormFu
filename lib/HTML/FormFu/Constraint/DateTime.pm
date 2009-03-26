package HTML::FormFu::Constraint::DateTime;

use strict;
use base 'HTML::FormFu::Constraint';
use Class::C3;

use DateTime::Format::Builder;

__PACKAGE__->mk_item_accessors(qw( _builder ));

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

HTML::FormFu::Constraint::DateTime - DateTime constraint

=head1 SYNOPSIS

    ---
    elements:
      - type: Text
        name: start_date
        constraints:
          - type: DateTime
            parser: 
              strptime: '%d-%m-%Y'
      
      - type: Text
        name: end_time
        constraints:
          - type: DateTime
            parser:
              regex: !!perl/regexp '^(\d{2}) - (\d{2}) - (\d{4})$'
              params: [day, month, year]

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

Ensure input can later be inflated to a DateTime object.

=head1 METHODS

=head2 parser

Arguments: \%args

Required. Define the expected input string, so L<DataTime::Format::Builder> 
knows how to turn it into a L<DateTime> object.

Accepts arguments to be passed to L<DateTime::Format::Builder/parser>.

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
