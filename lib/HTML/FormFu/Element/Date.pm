package HTML::FormFu::Element::Date;

use strict;
use base 'HTML::FormFu::Element::Multi';
use Class::C3;

use HTML::FormFu::Attribute qw/ mk_attrs /;
use HTML::FormFu::Util qw/ _filter_components _parse_args /;
use DateTime;
use DateTime::Format::Builder;
use DateTime::Format::Natural;
use DateTime::Locale;
use Scalar::Util qw/ blessed /;
use Carp qw/ croak /;

__PACKAGE__->mk_attrs(
    qw/
        day month year
        /
);

__PACKAGE__->mk_accessors(
    qw/
        strftime auto_inflate default_natural
        /
);

*default = \&value;

# build get_Xs methods
for my $method (
    qw/
    deflator filter constraint inflator validator transformer /
    )
{
    my $sub = sub {
        my $self       = shift;
        my %args       = _parse_args(@_);
        my $get_method = "get_${method}s";

        my $accessor = "_${method}s";
        my @x        = @{ $self->$accessor };
        push @x, map { @{ $_->$get_method(@_) } } @{ $self->_elements };

        return _filter_components( \%args, \@x );
    };

    my $name = __PACKAGE__ . "::get_${method}s";

    no strict 'refs';

    *{$name} = $sub;
}

sub new {
    my $self = shift->next::method(@_);

    $self->strftime("%d-%m-%Y");
    $self->day( {
            type   => '_DateSelect',
            prefix => [],
        } );
    $self->month( {
            type   => '_DateSelect',
            prefix => [],
        } );
    $self->year( {
            type   => '_DateSelect',
            prefix => [],
            less   => 0,
            plus   => 10,
        } );

    return $self;
}

sub value {
    my $self = shift;

    if (@_) {
        $self->{value} = shift;

        # if we're already built - i.e. process() has ben called,
        # call default() on our children

        if ( @{ $self->_elements } ) {
            $self->_date_defaults;

            $self->_elements->[0]->default( $self->day->{default} );
            $self->_elements->[1]->default( $self->month->{default} );
            $self->_elements->[2]->default( $self->year->{default} );
        }

        return $self;
    }

    return $self->{value};
}

sub _add_elements {
    my $self = shift;

    $self->_elements( [] );

    $self->_date_defaults;

    $self->_add_day;
    $self->_add_month;
    $self->_add_year;

    if ( $self->auto_inflate
        && !@{ $self->get_inflators( { type => "DateTime" } ) } )
    {
        _add_inflator($self);
    }

    return;
}

sub _date_defaults {
    my $self = shift;

    my $default;
    if ( defined( $default = $self->default_natural ) ) {
        my $parser = DateTime::Format::Natural->new;
        $default = $parser->parse_datetime($default);
    }
    elsif ( defined( $default = $self->default ) ) {
        my $is_blessed = blessed($default);

        if ( !$is_blessed || ( $is_blessed && !$default->isa('DateTime') ) ) {
            my $builder = DateTime::Format::Builder->new;
            $builder->parser( { strptime => $self->strftime } );

            $default = $builder->parse_datetime($default);
        }
    }

    if ( defined $default ) {
        $self->day->{default}   = $default->day;
        $self->month->{default} = $default->month;
        $self->year->{default}  = $default->year;
    }

    return;
}

sub _add_day {
    my ($self) = @_;

    my $day = $self->day;

    my $day_name = _build_day_name($self);

    my @day_prefix = map { [ '', $_ ] }
        ref $day->{prefix} ? @{ $day->{prefix} } : $day->{prefix};

    $self->element( {
            type    => $day->{type},
            name    => $day_name,
            options => [ @day_prefix, map { [ $_, $_ ] } 1 .. 31 ],
            defined $day->{default}
            ? ( default => $day->{default} )
            : (),
        } );

    return;
}

sub _add_month {
    my ($self) = @_;

    my $month = $self->month;

    my $month_name = _build_month_name($self);

    my @months = _build_month_list($self);

    my @month_prefix = map { [ '', $_ ] }
        ref $month->{prefix} ? @{ $month->{prefix} } : $month->{prefix};

    $self->element( {
            type => $month->{type},
            name => $month_name,
            options =>
                [ @month_prefix, map { [ $_ + 1, $months[$_] ] } 0 .. 11 ],
            defined $month->{default}
            ? ( default => $month->{default} )
            : (),
        } );

    return;
}

sub _add_year {
    my ($self) = @_;

    my $year = $self->year;

    my $year_name = _build_year_name($self);

    my $year_ref
        = defined $year->{reference}
        ? $year->{reference}
        : ( localtime(time) )[5] + 1900;

    my @years
        = defined $year->{list}
        ? @{ $year->{list} }
        : ( $year_ref - $year->{less} ) .. ( $year_ref + $year->{plus} );

    my @year_prefix = map { [ '', $_ ] }
        ref $year->{prefix} ? @{ $year->{prefix} } : $year->{prefix};

    $self->element( {
            type    => $year->{type},
            name    => $year_name,
            options => [ @year_prefix, map { [ $_, $_ ] } @years ],
            defined $year->{default}
            ? ( default => $year->{default} )
            : (),
        } );

    return;
}

sub _build_month_list {
    my ($self) = @_;

    my $month = $self->month;
    my @months;

    if ( defined $month->{names} ) {
        @months = @{ $month->{names} };
    }
    else {
        for my $lang ( @{ $self->form->languages } ) {
            my $loc;
            eval { $loc = DateTime::Locale->load($lang); };
            if ( !$@ ) {
                @months
                    = map {ucfirst}
                    $month->{short_names}
                    ? @{ $loc->month_abbreviations }
                    : @{ $loc->month_names };

                last;
            }
        }
    }

    return @months;
}

sub _build_day_name {
    my ($self) = @_;

    my $day_name
        = defined $self->day->{name}
        ? $self->day->{name}
        : sprintf "%s_day", $self->name;

    return $day_name;
}

sub _build_month_name {
    my ($self) = @_;

    my $month_name
        = defined $self->month->{name}
        ? $self->month->{name}
        : sprintf "%s_month", $self->name;

    return $month_name;
}

sub _build_year_name {
    my ($self) = @_;

    my $year_name
        = defined $self->year->{name}
        ? $self->year->{name}
        : sprintf "%s_year", $self->name;

    return $year_name;
}

sub _add_inflator {
    my ($self) = @_;

    $self->inflator( {
            type     => "DateTime",
            parser   => { strptime => $self->strftime, },
            strptime => $self->strftime,
        } );

    return;
}

sub process {
    my $self = shift;

    $self->_add_elements;

    return $self->next::method(@_);
}

sub process_input {
    my ( $self, $input ) = @_;

    my $day_name   = _build_day_name($self);
    my $month_name = _build_month_name($self);
    my $year_name  = _build_year_name($self);

    $day_name   = $self->get_element( { name => $day_name } )->nested_name;
    $month_name = $self->get_element( { name => $month_name } )->nested_name;
    $year_name  = $self->get_element( { name => $year_name } )->nested_name;

    my $day   = $self->get_nested_hash_value( $input, $day_name );
    my $month = $self->get_nested_hash_value( $input, $month_name );
    my $year  = $self->get_nested_hash_value( $input, $year_name );

    if (   defined $day
        && length $day
        && defined $month
        && length $month
        && defined $year
        && length $year )
    {
        my $dt;

        eval {
            $dt = DateTime->new(
                day   => $day,
                month => $month,
                year  => $year,
            );
        };

        my $value;

        if ($@) {
            $value = $self->strftime;
        }
        else {
            $value = $dt->strftime( $self->strftime );
        }

        $self->set_nested_hash_value( $input, $self->nested_name, $value );
    }

    return $self->next::method($input);
}

sub render_data {
    return shift->render_data_non_recursive(@_);
}

sub render_data_non_recursive {
    my $self = shift;

    my $render = $self->next::method( {
            elements => [ map { $_->render_data } @{ $self->_elements } ],
            @_ ? %{ $_[0] } : () } );

    return $render;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::Date - 3 select menu multi-field

=head1 SYNOPSIS

    ---
    elements:
      - type: Date
        name: birthdate
        label: 'Birthdate:'
        day:
          prefix: "- Day -"
        month:
          prefix: "- Month -"
        year:
          prefix: "- Year -"
          less: 70
          plus: 0
        auto_inflate: 1


=head1 DESCRIPTION

Creates a L<multi|HTML::FormFu::Element::Multi> element containing 3 select 
menus for the day, month and year.

A date element named C<foo> would result in 3 select menus with the names 
C<foo_day>, C<foo_month> and C<foo_year>. The names can instead be 
overridden by the C<name> value in L</day>, L</month> and L</year>.

This element automatically merges the input parameters from the select 
menu into a single date parameter (and doesn't delete the individual menu's 
parameters).

=head1 METHODS

=head2 default

Arguments: DateTime object

Arguments: $date_string

Accepts either a L<DateTime> object, or a string containing a date, matching 
the L</strftime> format. Overwrites any default value set in L</day>, 
L</month> or L</year>.

=head2 default_natural

Arguments: $date_string

    - type: Date
      default_natural: 'today'

Accepts a date/time string suitable for passing to
L<DateTime::Format::Natural/parse_datetime>.

=head2 strftime

Default Value: "%d-%m-%Y"

The format of the date as returned by L<HTML::FormFu/params>, if 
L</auto_inflate> is not set.

If L</auto_inflate> is used, this is still the format that the parameter 
will be in prior to the DateTime inflator being run; which is 
what any L<Filters|HTML::FormFu::Filter> and 
L<Constraints|HTML::FormFu::Constraint> will receive.

=head2 day

Arguments: \%setting

Set values effecting the C<day> select menu. Known keys are:

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

=head2 month

Arguments: \%setting

Set values effecting the C<month> select menu. Known keys are:

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

=head3 names

Arguments: \@months

A list of month names used for the month menu.

If not set, the list of month names is obtained from L<DateTime::Locale> 
using the locale set in L<HTML::FormFu/languages>.

=head3 short_names

Argument: bool

If true (and C<months> is not set) the list of abbreviated month names is 
obtained from L<DateTime::Locale> using the locale set in 
L<HTML::FormFu/languages>.

=head2 year

Arguments: \%setting

Set values effecting the C<year> select menu. Known keys are:

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

=head3 list

Arguments: \@years

A list of years used for the year menu.

If this is set, C<reference>, C<less> and C<plus> are ignored.

=head3 reference

Arguments: $year

Default Value: the current year, calculated from L<time()|perlfunc/time()>

If C<list> is not set, the list is created from the range of 
C<reference - year_less> to C<reference + year_plus>.

=head3 less

Arguments: $count

Default Value: 0

=head3 plus

Arguments: $count

Default Value: 10

=head2 auto_inflate

If true, a L<DateTime Inflator|HTML::FormFu::Inflator::DateTime> will 
automatically be added to the element, and it will be given a formatter so 
that stringification will result in the format specified in L</strftime>.

If you require the DateTime Inflator to have a different stringification 
format to the format used internally by your Filters and Constraints, then 
you must explicitly add your own DateTime Inflator, rather than using 
L</auto_inflate>.

=head1 CAVEATS

Although this element inherits from L<HTML::FormFu::Element::Block>, it's 
behaviour for the methods 
L<filter/filters|HTML::FormFu/filters>, 
L<constraint/constraints|HTML::FormFu/constraints>, 
L<inflator/inflators|HTML::FormFu/inflators>, 
L<validator/validators|HTML::FormFu/validators> and 
L<transformer/transformers|HTML::FormFu/transformers> is more like that of 
a L<field element|HTML::FormFu::Element::_Field>, meaning all processors are 
added directly to the date element, not to it's select-menu child elements.

This element's L<get_elements|HTML::FormFu/get_elements> and 
L<get_all_elements|HTML::FormFu/get_all_elements> are inherited from 
L<HTML::FormFu::Element::Block>, and so have the same behaviour. However, it 
overrides the C<get_fields> method, such that it returns both itself and 
it's child elements.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::_Field>, 
L<HTML::FormFu::Element::Multi>, 
L<HTML::FormFu::Element::Block>, 
L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
