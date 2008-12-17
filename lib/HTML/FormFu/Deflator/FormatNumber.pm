package HTML::FormFu::Deflator::FormatNumber;

use warnings;
use strict;
use base 'HTML::FormFu::Deflator';
use Number::Format;
use POSIX;
use Carp;

__PACKAGE__->mk_item_accessors(qw(locale precision trailing_zeroes));

sub new {
  my $self = shift->next::method(@_);
  $self->locale($self->form->locale);
  $self->precision(2);
  $self->trailing_zeroes(0);
  return $self;
}

sub deflator {
  my ($self, $value) = @_;
  my $old = setlocale(LC_NUMERIC);
  setlocale(&LC_NUMERIC, $self->locale) or croak "Locale ".$self->locale." could not be found" if $self->locale;
  my $f = new Number::Format;
  $value = $f->format_number($value, $self->precision, $self->trailing_zeroes);
  setlocale(LC_NUMERIC, $old);
  return $value;
}

=head1 NAME

HTML::FormFu::Deflator::FormatNumber - Format a number to meet your needs

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

This deflator handels the formatting of numbers. It uses L<Number::Format>.

  - type: Text
    name: number
    deflators:
      - type: FormatNumber
        locale: de_DE
	precision: 4
  - type: Text
    name: price
    deflators:
      - type: FormatNumber
        locale: de_DE
	precision: 2
        trailing_zeroes: 1

  # "123456.22" will be transformed to "123.456,22" (german locale)

This example prints two input fields. You can specify the locale and this module will use the correct representation for the decimal separator etc. (e. g. C<,> for countries like Germany or France). C<precision> sets the precision the number should have. For fields like prices you can set C<trailing_zeroes> to 1 if you wish the trailing zeroes to appear.

C<locale> is optional. If omitted the system's locale will be used.

=head1 AUTHOR

Moritz Onken, C<< <onken at houseofdesign.de> >>

=head1 SEE ALSO

L<HTML::FormFu::Inflator::FormatNumber>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Moritz Onken, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of HTML::FormFu::Deflator::FormatNumber
