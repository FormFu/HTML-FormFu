package HTML::FormFu::Filter::FormatNumber;

use strict;
use base 'HTML::FormFu::Filter';

use Number::Format;
use POSIX qw( setlocale LC_NUMERIC );

__PACKAGE__->mk_inherited_accessors(qw( locale ));

sub filter {
    my ( $self, $value ) = @_;

    my $backup_locale = setlocale(LC_NUMERIC);

    if ( my $locale = $self->locale ) {

       # if unable to set locale, this isn't a validation error that the user
       # should see, so return the original value, rather than throwing an error

        setlocale( LC_NUMERIC, $locale )
            or return $value;
    }

    my $format = Number::Format->new;

    $value = $format->unformat_number($value);

    # restore orginal locale
    setlocale( LC_NUMERIC, $backup_locale );

    return $value;
}

1;

__END__

=head1 NAME

HTML::FormFu::Filter::FormatNumber - Convert a formatted number from a known locale

=head1 SYNOPSIS

This filter simply does the opposite of
L<HTML::FormFu::Deflator::FormatNumber>. It removes all thousands separators
and decimal points and returns the raw number which can be handled by perl.
See L<Number::Format/unformat_number> for more details.

    locale: de_DE
    elements:
      - type: Text
        name: number
        filters:
          - type: FormatNumber

    # An input value like "13.233.444,22" will be transformed to "13233444.22"
    # Same for "13233444,22"

=head1 METHODS

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

Is a sub-class of, and inherits methods from L<HTML::FormFu::Filter>

L<HTML::FormFu::Deflator::FormatNumber>

L<HTML::FormFu>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Moritz Onken, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
