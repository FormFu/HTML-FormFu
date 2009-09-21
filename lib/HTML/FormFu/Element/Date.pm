package HTML::FormFu::Element::Date;

use strict;
use base 'HTML::FormFu::Element::Multi';
use Class::C3;

use HTML::FormFu::Util qw( _filter_components _parse_args );
use DateTime;
use DateTime::Format::Builder;
use DateTime::Format::Natural;
use DateTime::Locale;
use Scalar::Util qw( blessed );
use List::MoreUtils qw( all none uniq );
use Carp qw( croak );

__PACKAGE__->mk_attrs(qw( day  month  year ));

__PACKAGE__->mk_accessors( qw(
        _known_fields
        printf_day
        printf_month
        printf_year
) );

__PACKAGE__->mk_item_accessors( qw(
        strftime
        auto_inflate
        default_natural
) );

*default = \&value;

# build get_Xs methods
for my $method ( qw(
    deflator        filter
    constraint      inflator
    validator       transformer
    ) )
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

    $self->_known_fields( [qw/ day month year /] );

    $self->printf_day  ('%d');
    $self->printf_month('%d');
    $self->printf_year ('%d');

    $self->field_order( [qw/ day month year /] );

    $self->day( {
            type   => '_MultiSelect',
            prefix => [],
        } );

    $self->month( {
            type   => '_MultiSelect',
            prefix => [],
        } );

    $self->year( {
            type   => '_MultiSelect',
            prefix => [],
            less   => 0,
            plus   => 10,
        } );

    return $self;
}

sub value {
    my ( $self, $value ) = @_;

    if ( @_ > 1 ) {
        $self->{value} = $value;

        # if we're already built - i.e. process() has ben called,
        # call default() on our children

        if ( @{ $self->_elements } ) {
            $self->_date_defaults;

            my @order = @{ $self->field_order };

            for my $i ( 0 .. $#order ) {
                my $field = $order[$i];

                my $printf_method = "printf_$field";

                my $default = $value
                    ? sprintf( $self->$printf_method, $self->$field->{default} )
                    : undef;

                $self->_elements->[$i]->default($default);
            }
        }

        return $self;
    }

    return $self->{value};
}

sub _add_elements {
    my ($self) = @_;

    $self->_elements( [] );

    $self->_date_defaults;

    for my $order ( @{ $self->field_order } ) {
        my $method = "_add_$order";

        $self->$method;
    }

    if ( $self->auto_inflate
        && !@{ $self->get_inflators( { type => "DateTime" } ) } )
    {
        _add_inflator($self);
    }

    return;
}

sub _date_defaults {
    my ($self) = @_;

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
        for my $field ( @{ $self->field_order } ) {
            $self->$field->{default} = $default->$field;
        }
    }

    return;
}

sub _add_day {
    my ($self) = @_;

    my $day = $self->day;

    my $day_name = $self->_build_name('day');

    my @day_prefix
        = ref $day->{prefix}
        ? @{ $day->{prefix} }
        : $day->{prefix};

    @day_prefix = map { [ '', $_ ] } @day_prefix;

    $self->element( {
            type    => $day->{type},
            name    => $day_name,
            options => [ @day_prefix, map { [ $_, $_ ] } 1 .. 31 ],

            defined $day->{default} ? ( default => $day->{default} ) : (),
        } );

    return;
}

sub _add_month {
    my ($self) = @_;

    my $month = $self->month;

    my $month_name = $self->_build_name('month');

    my @months = _build_month_list($self);

    my @month_prefix
        = ref $month->{prefix}
        ? @{ $month->{prefix} }
        : $month->{prefix};

    @month_prefix = map { [ '', $_ ] } @month_prefix;

    my $options = [ @month_prefix, map { [ $_ + 1, $months[$_] ] } 0 .. 11 ];

    $self->element( {
            type    => $month->{type},
            name    => $month_name,
            options => $options,

            defined $month->{default} ? ( default => $month->{default} ) : (),
        } );

    return;
}

sub _add_year {
    my ($self) = @_;

    my $year = $self->year;

    my $year_name = $self->_build_name('year');

    my $year_ref
        = defined $year->{reference}
        ? $year->{reference}
        : ( localtime(time) )[5] + 1900;

    my @years
        = defined $year->{list}
        ? @{ $year->{list} }
        : ( $year_ref - $year->{less} ) .. ( $year_ref + $year->{plus} );

    my @year_prefix
        = ref $year->{prefix}
        ? @{ $year->{prefix} }
        : $year->{prefix};

    @year_prefix = map { [ '', $_ ] } @year_prefix;

    $self->element( {
            type    => $year->{type},
            name    => $year_name,
            options => [ @year_prefix, map { [ $_, $_ ] } @years ],

            defined $year->{default} ? ( default => $year->{default} ) : (),
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
        my $languages = $self->form->languages;
        if ( ref $languages ne 'ARRAY' ) {
            $languages = [$languages];
        }

        for my $lang (@$languages) {
            my $loc;

            eval { $loc = DateTime::Locale->load($lang) };
            if ( !$@ ) {
                @months
                    = $month->{short_names}
                    ? @{ $loc->month_abbreviations }
                    : @{ $loc->month_names };

                @months = map {ucfirst} @months;

                last;
            }
        }
    }

    return @months;
}

sub _build_name {
    my ( $self, $type ) = @_;

    my $name
        = defined $self->$type->{name}
        ? $self->$type->{name}
        : sprintf "%s_%s", $self->name, $type;

    return $name;
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

sub field_order {
    my ( $self, @order ) = @_;

    if ( @_ > 1 ) {
        if ( @order == 1 && ref( $order[0] ) eq 'ARRAY' ) {
            @order = @{ $order[0] };
        }

        for my $field (@order) {
            croak "unknown field type: '$field'"
                if none { $field eq $_ } @{ $self->_known_fields };
        }

        croak 'repeated field type'
            if scalar( uniq @order ) != scalar(@order);

        $self->{field_order} = \@order;

        return $self;
    }
    else {
        return $self->{field_order};
    }
}

sub process {
    my ( $self, @args ) = @_;

    $self->_add_elements;

    return $self->next::method(@args);
}

sub process_input {
    my ( $self, $input ) = @_;

    my %value;

    my @order = @{ $self->field_order };

    for my $i ( 0 .. $#order ) {
        my $field = $order[$i];

        my $name = $self->_elements->[$i]->nested_name;

        $value{$field} = $self->get_nested_hash_value( $input, $name );
    }

    if ( ( all {defined} values %value )
        && all {length} values %value )
    {
        my $dt;

        eval {
            $dt = DateTime->new( map { $_, $value{$_} } keys %value );
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
    my ( $self, $args ) = @_;

    my $render = $self->next::method( {
            elements => [ map { $_->render_data } @{ $self->_elements } ],
            $args ? %$args : (),
        } );

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

=head2 field_order

Arguments: \@fields

Default Value: ['day', 'month', 'year']

Specify the order of the date fields in the rendered HTML.

Not all 3 fields are required. No single field can be used more than once.

=head2 auto_inflate

If true, a L<DateTime Inflator|HTML::FormFu::Inflator::DateTime> will 
automatically be added to the element, and it will be given a formatter so 
that stringification will result in the format specified in L</strftime>.

If you require the DateTime Inflator to have a different stringification 
format to the format used internally by your Filters and Constraints, then 
you must explicitly add your own DateTime Inflator, rather than using 
L</auto_inflate>.

=head1 CAVEATS

Although this element inherits from L<HTML::FormFu::Element::Block>, its 
behaviour for the methods 
L<filter/filters|HTML::FormFu/filters>, 
L<constraint/constraints|HTML::FormFu/constraints>, 
L<inflator/inflators|HTML::FormFu/inflators>, 
L<validator/validators|HTML::FormFu/validators> and 
L<transformer/transformers|HTML::FormFu/transformers> is more like that of 
a L<field element|HTML::FormFu::Element::_Field>, meaning all processors are 
added directly to the date element, not to its select-menu child elements.

This element's L<get_elements|HTML::FormFu/get_elements> and 
L<get_all_elements|HTML::FormFu/get_all_elements> are inherited from 
L<HTML::FormFu::Element::Block>, and so have the same behaviour. However, it 
overrides the C<get_fields> method, such that it returns both itself and 
its child elements.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
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
