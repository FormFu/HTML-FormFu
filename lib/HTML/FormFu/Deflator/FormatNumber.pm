package HTML::FormFu::Deflator::FormatNumber;

use strict;
use base 'HTML::FormFu::Deflator';

use Number::Format;
use POSIX qw( setlocale LC_NUMERIC );

__PACKAGE__->mk_item_accessors(qw( precision trailing_zeroes ));

sub new {
    my $self = shift->next::method(@_);

    $self->precision(2);
    $self->trailing_zeroes(0);

    return $self;
}

sub deflator {
    my ( $self, $value ) = @_;

    my $backup_locale = setlocale(LC_NUMERIC);

    if ( my $locale = $self->locale ) {

        # throwing errors from deflator() isn't supported
        # if unable to set locale, return the original value

        setlocale( LC_NUMERIC, $locale )
            or return $value;
    }

    my $format = Number::Format->new;

    $value = $format->format_number( $value, $self->precision,
        $self->trailing_zeroes );

    # restore locale
    setlocale( LC_NUMERIC, $backup_locale );

    return $value;
}

1;

__END__

=head1 NAME

HTML::FormFu::Deflator::FormatNumber - Format a number for a locale

=head1 SYNOPSIS

    locale: de_DE
    elements:
      - type: Text
        name: number
        deflators:
          - type: FormatNumber
            precision: 4
      
      - type: Text
        name: price
        deflators:
          - type: FormatNumber
            precision: 2
            trailing_zeroes: 1

    # "123456.22" will be rendered to "123.456,22" (german locale)

=head2 locale

If no locale is found, the server's locale will be used.

This method is a special 'inherited accessor', which means it can be set on 
the form, a enclosing block element, the field, or this filter.
When the value is read, if no value is defined it automatically traverses
the element's hierarchy of parents, through any block elements and up to the
form, searching for a defined value.

=head1 AUTHOR

Moritz Onken, C<onken at houseofdesign.de>

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Deflator>

L<HTML::FormFu::Filter::FormatNumber>

L<HTML::FormFu>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Moritz Onken, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
