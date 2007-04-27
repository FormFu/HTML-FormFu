package HTML::FormFu::Inflator::DateTime;

use strict;
use warnings;
use base 'HTML::FormFu::Inflator';

use DateTime::Format::Builder;

__PACKAGE__->mk_accessors(qw/ _builder /);

sub new {
    my $self = shift->SUPER::new(@_);

    $self->_builder( DateTime::Format::Builder->new );

    return $self;
}

sub parser {
    my $self = shift;

    $self->_builder->parser(@_);
}

sub inflator {
    my ( $self, $value ) = @_;

    return unless defined $value;

    return $self->_builder->parse_datetime($value);
}

sub clone {
    my $self = shift;
    
    my $clone = $self->SUPER::clone(@_);
    
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
      - type: text
        name: start_date
        inflators:
          - type: DateTime
            parser: 
              strptime: '%d-%m-%Y'
      - type: text
        name: end_time
        inflators:
          - type: DateTime
            parser:
              regex: '^ (\d{2}) - (\d{2}) - (\d{4}) $'
              params: [day, month, year]

=head1 DESCRIPTION

DateTime inflator.

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
