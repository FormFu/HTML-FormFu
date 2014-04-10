package HTML::FormFu::Element::DateTime;

use Moose;
use MooseX::Attribute::FormFuChained;
extends 'HTML::FormFu::Element::Date';

use Moose::Util qw( apply_all_roles );
use Scalar::Util qw( blessed );

__PACKAGE__->mk_attrs(qw/ hour minute second /);

for my $name ( qw(
    printf_hour
    printf_minute
    printf_second
    ) )
{
    has $name => (
        is      => 'rw',
        default => '%02d',
        lazy    => 1,
        traits  => ['FormFuChained'],
    );
}

after BUILD => sub {
    my ( $self, $args ) = @_;

    $self->strftime("%d-%m-%Y %H:%M");

    $self->_known_fields( [qw/ day month year hour minute second /] );

    $self->field_order( [qw( day month year hour minute )] );

    $self->hour( { prefix => [], } );

    $self->minute( { prefix => [], } );

    $self->second( { prefix => [], } );

    $self->printf_hour('%02d');
    $self->printf_minute('%02d');
    $self->printf_second('%02d');

    return;
};

sub _add_hour {
    my ($self) = @_;

    my $hour = $self->hour;

    my $hour_name = $self->_build_name('hour');

    my @hour_prefix
        = ref $hour->{prefix}
        ? @{ $hour->{prefix} }
        : $hour->{prefix};

    if ( exists $hour->{prefix_loc} ) {
        @hour_prefix
            = ref $hour->{prefix_loc}
            ? map { $self->form->localize($_) } @{ $hour->{prefix_loc} }
            : $self->form->localize( $hour->{prefix_loc} );
    }

    @hour_prefix = map { [ '', $_ ] } @hour_prefix;

    my $element = $self->element( {
            type    => 'Select',
            name    => $hour_name,
            options => [
                @hour_prefix,
                map { [ $_, $_ ] } map { sprintf '%02d', $_ } 0 .. 23
            ],
            attributes => $hour->{attributes},

            defined $hour->{default}
            ? ( default => sprintf '%02d', $hour->{default} )
            : (),
        } );

    apply_all_roles( $element, 'HTML::FormFu::Role::Element::MultiElement' );

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

    if ( exists $minute->{prefix_loc} ) {
        @minute_prefix
            = ref $minute->{prefix_loc}
            ? map { $self->form->localize($_) } @{ $minute->{prefix_loc} }
            : $self->form->localize( $minute->{prefix_loc} );
    }

    @minute_prefix = map { [ '', $_ ] } @minute_prefix;

    my @minutes = $self->_build_number_list( 0, 59, $minute->{interval} );

    my $element = $self->element( {
            type    => 'Select',
            name    => $minute_name,
            options => [
                @minute_prefix,
                map { [ $_, $_ ] } map { sprintf '%02d', $_ } @minutes
            ],
            attributes => $minute->{attributes},

            defined $minute->{default}
            ? ( default => sprintf '%02d', $minute->{default} )
            : (),
        } );

    apply_all_roles( $element, 'HTML::FormFu::Role::Element::MultiElement' );

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

    if ( exists $second->{prefix_loc} ) {
        @second_prefix
            = ref $second->{prefix_loc}
            ? map { $self->form->localize($_) } @{ $second->{prefix_loc} }
            : $self->form->localize( $second->{prefix_loc} );
    }

    @second_prefix = map { [ '', $_ ] } @second_prefix;

    my @seconds = $self->_build_number_list( 0, 59, $second->{interval} );

    my $element = $self->element( {
            type    => 'Select',
            name    => $second_name,
            options => [
                @second_prefix,
                map { [ $_, $_ ] } map { sprintf '%02d', $_ } @seconds
            ],
            attributes => $second->{attributes},

            defined $second->{default}
            ? ( default => sprintf '%02d', $second->{default} )
            : (),
        } );

    apply_all_roles( $element, 'HTML::FormFu::Role::Element::MultiElement' );

    return;
}

__PACKAGE__->meta->make_immutable;

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

=head3 prefix_loc

Arguments: $localization_key

Arguments: \@localization_keys

A localized string or arrayref of localized strings to be inserted into the
start of the select menu.

Each value is localized and then only used as the label for a select item
- the value for each of these items is always the empty string C<''>.

Use C<prefix_loc> insted of C<prefix>.

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

=head3 prefix_loc

Arguments: $localization_key

Arguments: \@localization_keys

A localized string or arrayref of localized strings to be inserted into the
start of the select menu.

Each value is localized and then only used as the label for a select item
- the value for each of these items is always the empty string C<''>.

Use C<prefix_loc> insted of C<prefix>.

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

=head3 prefix_loc

Arguments: $localization_key

Arguments: \@localization_keys

A localized string or arrayref of localized strings to be inserted into the
start of the select menu.

Each value is localized and then only used as the label for a select item
- the value for each of these items is always the empty string C<''>.

Use C<prefix_loc> insted of C<prefix>.

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
L<HTML::FormFu::Role::Element::Field>, 
L<HTML::FormFu::Element::Multi>, 
L<HTML::FormFu::Element::Block>, 
L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
