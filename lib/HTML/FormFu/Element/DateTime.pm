package HTML::FormFu::Element::DateTime;

use strict;
use base 'HTML::FormFu::Element::Date';

use Scalar::Util qw( blessed );

__PACKAGE__->mk_attrs(qw/ hour minute second /);

__PACKAGE__->mk_accessors(qw/ printf_hour printf_minute printf_second /);

sub new {
    my $self = shift->next::method(@_);

    $self->strftime("%d-%m-%Y %H:%M");

    $self->_known_fields( [qw/ day month year hour minute second /] );

    $self->field_order( [qw/ day month year hour minute /] );

    $self->hour( {
            type   => '_MultiSelect',
            prefix => [],
        } );

    $self->minute( {
            type   => '_MultiSelect',
            prefix => [],
        } );

    $self->second( {
            type   => '_MultiSelect',
            prefix => [],
        } );

    $self->printf_hour  ('%02d');
    $self->printf_minute('%02d');
    $self->printf_second('%02d');

    return $self;
}

sub _add_hour {
    my ($self) = @_;

    my $hour = $self->hour;

    my $hour_name = $self->_build_name('hour');

    my @hour_prefix
        = ref $hour->{prefix}
        ? @{ $hour->{prefix} }
        : $hour->{prefix};

    @hour_prefix = map { [ '', $_ ] } @hour_prefix;

    $self->element( {
            type    => $hour->{type},
            name    => $hour_name,
            options => [
                @hour_prefix,
                map { [ $_, $_ ] } map { sprintf '%02d', $_ } 0 .. 23
            ],

            defined $hour->{default}
            ? ( default => sprintf '%02d', $hour->{default} )
            : (),
        } );

    return;
}

sub _add_minute {
    my ($self) = @_;

    my $minute = $self->minute;

    my $minute_name = $self->_build_name('minute');

    my @minute_prefix
        = ref $minute->{prefix}
        ? @{ $minute->{prefix} }
        : $minute->{prefix};

    @minute_prefix = map { [ '', $_ ] } @minute_prefix;

    $self->element( {
            type    => $minute->{type},
            name    => $minute_name,
            options => [
                @minute_prefix,
                map { [ $_, $_ ] } map { sprintf '%02d', $_ } 0 .. 59
            ],

            defined $minute->{default}
            ? ( default => sprintf '%02d', $minute->{default} )
            : (),
        } );

    return;
}

sub _add_second {
    my ($self) = @_;

    my $second = $self->second;

    my $second_name = $self->_build_name('second');

    my @second_prefix
        = ref $second->{prefix}
        ? @{ $second->{prefix} }
        : $second->{prefix};

    @second_prefix = map { [ '', $_ ] } @second_prefix;

    $self->element( {
            type    => $second->{type},
            name    => $second_name,
            options => [
                @second_prefix,
                map { [ $_, $_ ] } map { sprintf '%02d', $_ } 0 .. 59
            ],

            defined $second->{default}
            ? ( default => sprintf '%02d', $second->{default} )
            : (),
        } );

    return;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::DateTime - Date / Time combo field

=head1 SYNOPSIS

    ---
    elements:
      - type: DateTime
        name: start_datetime
        label: 'Start:'
        auto_inflate: 1


=head1 DESCRIPTION

Sub-class of L<Date element|HTML::FormFu::Element::Date>, providing extra
C<hour> and C<minute> Select menus.

=head1 METHODS

=head2 hour

Arguments: \%setting

Set values effecting the C<hour> select menu. Known keys are:

=head3 name

Override the auto-generated name of the select menu.

=head3 default

Set the default value of the select menu

=head3 prefix

Arguments: $value

Arguments: \@values

A string or arrayref of strings to be inserted into the start of the select 
menu.

Each value is only used as the label for a select item - the value for each 
of these items is always the empty string C<''>.

=head2 minute

Arguments: \%setting

Set values effecting the C<minute> select menu. Known keys are:

=head3 name

Override the auto-generated name of the select menu.

=head3 default

Set the default value of the select menu

=head3 prefix

Arguments: $value

Arguments: \@values

A string or arrayref of strings to be inserted into the start of the select 
menu.

Each value is only used as the label for a select item - the value for each 
of these items is always the empty string C<''>.

=head2 second

Arguments: \%setting

Set values effecting the C<second> select menu. Known keys are:

=head3 name

Override the auto-generated name of the select menu.

=head3 default

Set the default value of the select menu

=head3 prefix

Arguments: $value

Arguments: \@values

A string or arrayref of strings to be inserted into the start of the select 
menu.

Each value is only used as the label for a select item - the value for each 
of these items is always the empty string C<''>.

=head2 field_order

Arguments: \@fields

Default Value: ['day', 'month', 'year', 'hour', 'minute']

Specify the order of the date fields in the rendered HTML.

If you want the L</second> selector to display, you must set both
C</field_order> and L<strftime|HTML::FormFu::Element::DateTime/strftime>
yourself. Eg:

    elements:
      type: DateTime
      name: foo
      strftime: '%d-%m-%Y %H:%M:%S'
      field_order: ['day', 'month', 'year', 'hour', 'minute', 'second']

Not all fields are required. No single field can be used more than once.

=head1 CAVEATS

See L<HTML::FormFu::Element::Date/CAVEATS>

=head1 SEE ALSO

Is a sub-class of, and inherits methods from
L<HTML::FormFu::Element::Date>
L<HTML::FormFu::Element::_Field>, 
L<HTML::FormFu::Element::Multi>, 
L<HTML::FormFu::Element::Block>, 
L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
