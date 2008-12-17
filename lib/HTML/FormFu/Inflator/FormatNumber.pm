package HTML::FormFu::Inflator::FormatNumber;

use warnings;
use strict;
use base 'HTML::FormFu::Inflator';
use Number::Format;
use POSIX qw(locale_h);
use Carp;

__PACKAGE__->mk_item_accessors(qw(locale));

sub inflator {
  my ($self, $value) = @_;
  $self->locale($self->form->locale) unless($self->locale);
  my $old = setlocale(LC_NUMERIC);
  setlocale(LC_NUMERIC, $self->locale) or croak "Locale ".$self->locale." could not be found" if $self->locale;
  my $f = new Number::Format;
  setlocale(LC_NUMERIC, $old);
  no locale;
  $value = $f->unformat_number($value);
  return $value;
}

=head1 NAME

HTML::FormFu::Inflator::FormatNumber - Format numbers to meet your needs

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

This inflator simply does the opposite of L<HTML::FormFu::Deflator::FormatNumber>. It removes all thousands separators and decimal points and returns the raw number which can be handled by perl. See L<Number::Format/unformat_number> for more details.

  - type: Text
    name: number
    inflators:
      - type: FormatNumber
        locale: de_DE

  # An input value like "13.233.444,22" will be transformed to "13233444.22"
  # Same for "13233444,22"

You need to specify the same locale as you did in the deflator.

=head1 AUTHOR

Moritz Onken, C<< <onken at houseofdesign.de> >>

=head1 SEE ALSO

L<HTML::FormFu::Deflator::FormatNumber>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Moritz Onken, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of HTML::FormFu::Deflator::FormatNumber
