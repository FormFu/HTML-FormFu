package HTML::FormFu::Deflator::Strftime;

use strict;
use base 'HTML::FormFu::Deflator';

__PACKAGE__->mk_item_accessors(qw( strftime ));

sub deflator {
    my ( $self, $value ) = @_;

    my $return;

    eval {
        my $locale = $self->locale;

        $value->set_locale($locale) if defined $locale;
    };

    eval { $return = $value->strftime( $self->strftime ) };

    if ($@) {
        $return = $value;
    }

    return $return;
}

1;

__END__

=head1 NAME

HTML::FormFu::Deflator::Strftime - Strftime deflator

=head1 SYNOPSIS

    $form->deflator( Strftime => 'start_time' )
        ->strftime( '%d/%m/%Y' );

    ---
    elements:
        - type: Text
          inflators:
              - type: DateTime
                parser:
                    strptime: "%Y/%m/%d"
          deflator:
              - type: Strftime
                strftime: "%Y/%m/%d"

=head1 DESCRIPTION

Strftime deflator for L<DateTime> objects.

When you redisplay a form to the user following an invalid submission,
any fields with DateTime inflators will stringify to something like
'1970-01-01T00:00:00'. In most cases it makes more sense to use the same
format you've asked the user for. This deflator allows you to specify a
more suitable and user-friendly format.

This deflator calls L<DateTime>'s C<strftime> method. Possible values for
the format string are documented at
L<http://search.cpan.org/dist/DateTime/lib/DateTime.pm#strftime_Patterns>.

If you set the form's locale (see L<HTML::FormFu/locale>) this is set on the DateTime object. Now you can use C<%x> to get the default date or C<%X> for the default time for the object's locale.

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
