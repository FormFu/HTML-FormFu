package HTML::FormFu::Element::date;

use strict;
use warnings;
use base 'HTML::FormFu::Element::field', 'HTML::FormFu::Element::multi';
use Class::C3;

use HTML::FormFu::Attribute qw/ mk_require_methods /;
use HTML::FormFu::Util qw/ _get_elements /;
use DateTime;
use DateTime::Locale;
use Carp qw/ croak /;

__PACKAGE__->mk_accessors(qw/
    day_name month_name year_name
    months short_months years year year_less year_plus 
    day_prefix month_prefix year_prefix 
    day_default month_default year_default 
    strftime auto_inflate 
/);

# build get_Xs methods
for my $method (qw/ 
    deflator filter constraint inflator validator transformer /)
{
    my $sub = sub {
        my $self = shift;
        my %args = _parse_args(@_);
        my $get_method = "get_${method}s";
        
        my $accessor = "_${method}s";
        my @x = @{ $self->$accessor };
        push @x, map { @{ $_->$get_method(@_) } } @{ $self->_elements };
        
        if ( exists $args{name} ) {
            @x = grep { $_->name eq $args{name} } @x;
        }
        
        if ( exists $args{type} ) {
            @x = grep { $_->type eq $args{type} } @x;
        }
        
        return \@x;
        };
    
    my $name = __PACKAGE__ . "::get_${method}s";
    
    no strict 'refs';
        
    *{$name} = $sub;
}

sub new {
    my $self = shift->next::method(@_);

    $self->is_field(0);
    $self->render_class_suffix('multi');
    
    $self->strftime("%d-%m-%Y") if !defined $self->strftime;
    $self->year_less(0)         if !defined $self->year_less;
    $self->year_plus(10)        if !defined $self->year_plus;
    $self->day_prefix([])       if !defined $self->day_prefix;
    $self->month_prefix([])     if !defined $self->month_prefix;
    $self->year_prefix([])      if !defined $self->year_prefix;

    return $self;
}

sub get_fields {
    my $self = shift;
    
    my $f = $self->HTML::FormFu::Element::multi::get_fields(@_);
    
    unshift @$f, $self;
    
    return $f;
}

sub _add_elements {
    my $self = shift;
    
    $self->_elements([]);
    
    my $day_name = defined $self->day_name
                 ? $self->day_name
                 : sprintf "%s.day", $self->name;

    my $month_name = defined $self->month_name
                   ? $self->month_name
                   : sprintf "%s.month", $self->name;

    my $year_name = defined $self->year_name
                  ? $self->year_name
                  : sprintf "%s.year", $self->name;

    my @months;
    
    if ( defined $self->months ) {
        @months = @{ $self->months };
    }
    else {
        for my $lang ( @{ $self->form->languages } ) {
            my $loc;
            eval {
                $loc = DateTime::Locale->load( $lang );
            };
            if ( !$@ ) {
                @months = $self->short_months 
                    ? @{ $loc->month_abbreviations }
                    : @{ $loc->month_names };
                
                last;
            }
        }
    }
    
    my $year = defined $self->year
             ? $self->year
             : (localtime(time))[5] + 1900;

    my @years = defined $self->years
              ? @{ $self->years }
              : ( $year - $self->year_less ) .. ( $year + $self->year_plus );
    
    my @day_prefix   = map {[ '', $_ ]} 
        ref $self->day_prefix ? @{ $self->day_prefix } : $self->day_prefix;
    
    my @month_prefix = map {[ '', $_ ]} 
        ref $self->month_prefix ? @{ $self->month_prefix } : $self->month_prefix;
    
    my @year_prefix  = map {[ '', $_ ]} 
        ref $self->year_prefix ? @{ $self->year_prefix } : $self->year_prefix;

    $self->element({
        type => 'select',
        name => $day_name,
        options => [ @day_prefix, map {[ $_, $_ ]} 1..31 ],
        defined $self->day_default 
            ? ( default => $self->day_default )
            : (),
        });

    $self->element({
        type => 'select',
        name => $month_name,
        options => [ @month_prefix, map { [ $_+1, $months[$_] ] } 0..11 ],
        defined $self->month_default 
            ? ( default => $self->month_default )
            : (),
        });

    $self->element({
        type => 'select',
        name => $year_name,
        options => [ @year_prefix, map {[ $_, $_ ]} @years ],
        defined $self->year_default 
            ? ( default => $self->year_default )
            : (),
        });
    
    if ( $self->auto_inflate 
        && !@{ $self->get_inflators({ type => "DateTime" }) } )
    {
        $self->_add_inflator
    }
    
    return;
}

sub _add_inflator {
    my $self = shift;
    
    $self->_inflators([]);
    
    $self->inflator({
        type => "DateTime",
        parser => {
            strptime => $self->strftime,
            },
        strptime => $self->strftime,
        });
    
    return;
}

sub process {
    my $self = shift;
    
    $self->_add_elements;
    
}

sub process_input {
    my ( $self, $input ) = @_;
    
    my $day_name = defined $self->day_name
                 ? $self->day_name
                 : sprintf "%s.day", $self->name;

    my $month_name = defined $self->month_name
                   ? $self->month_name
                   : sprintf "%s.month", $self->name;

    my $year_name = defined $self->year_name
                  ? $self->year_name
                  : sprintf "%s.year", $self->name;
    
    if ( defined $input->{$day_name}
      && defined $input->{$month_name}
      && defined $input->{$year_name} )
    {
        my $dt;
        
        eval {
            $dt = DateTime->new(
                day   => $input->{$day_name},
                month => $input->{$month_name},
                year  => $input->{$year_name},
            );
        };
        
        if ( $@ ) {
            $input->{ $self->name } = $self->strftime;
        }
        else {
            $input->{ $self->name } = $dt->strftime( $self->strftime );
        }
    }
    
    return;
}

sub render {
    my $self = shift;
    
    $self->_add_elements;

    my $render = $self->next::method({
        @_ ? %{$_[0]} : ()
        });

    return $render;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::date - 3 select menu multi-field

=head1 SYNOPSIS

    ---
    elements:
      - type: date
        name: foo
        auto_inflate: 1

=head1 DESCRIPTION

Creates a L<multi|HTML::FormFu::Element::multi> element containing 3 select 
menus for the day, month and year.

A date element named C<foo> would result in 3 select menus with the names 
C<foo.day>, C<foo.month> and C<foo.year>. The names can instead be 
explicitly specified with L</day_name>, L</month_name> and L</year_name>.

This element automatically merges the input parameters from the select 
menu into a single date parameter (and doesn't delete the individual menu's 
parameters).

=head1 METHODS

=head2 strftime

Default Value: "%d-%m-%Y"

The format of the date as returned by L<HTML::FormFu/params>, if 
L</auto_inflate> is not set.

If L</auto_inflate> is used, this is still the format that the parameter 
will be in prior to the DateTime inflator being run; which is 
what any L<Filters|HTML::FormFu::Filter> and 
L<Constraints|HTML::FormFu::Constraint> will receive.

=head2 auto_inflate

If true, a L<DateTime Inflator|HTML::FormFu::Inflator::DateTime> will 
automatically be added to the element, and it will be given a formatter so 
that stringification will result in the format specified in L</strftime>.

If you require the DateTime Inflator to have a different stringification 
format to the format used internally by your Filters and Constraints, then 
you must explicitly add your own DateTime Inflator, rather than using 
L</auto_inflate>.

=head2 months

Arguments: \@months

A list of month names used for the month menu.

If not set, the list of month names is obtained from L<DateTime::Locale> 
using the locale set in L<HTML::FormFu/languages>.

=head2 short_months

If true (and L</months> is not set) the list of abbreviated month names is 
obtained from L<DateTime::Locale> using the locale set in 
L<HTML::FormFu/languages>.

=head2 years

Arguments: \@years

A list of years used for the year menu. Overrides L</year>.

=head2 year

Default Value: the current year, calculated from L<time()|perlfunc/time()>

If the L</years> list is not set, the list is created from the range of 
C<year - year_less> to C<year + year_plus>.

=head2 year_less

Default Value: 0

=head2 year_plus

Default Value: 10

=head1 CAVEATS

Although this element inherits from L<HTML::FormFu::Element::block>, it's 
behaviour for the methods 
L<filter/filters|HTML::FormFu/filters>, 
L<constraint/constraints|HTML::FormFu/constraints>, 
L<inflator/inflators|HTML::FormFu/inflators>, 
L<validator/validators|HTML::FormFu/validators> and 
L<transformer/transformers|HTML::FormFu/transformers> is more like that of 
a L<field element|HTML::FormFu::Element::field>, meaning all processors are 
added directly to the date element, not to it's select-menu child elements.

This element's L<get_elements|HTML::FormFu/get_elements> and 
L<get_all_elements|HTML::FormFu/get_all_elements> are inherited from 
L<HTML::FormFu::Element::block>, and so have the same behaviour. However, it 
overrides the C<get_fields> method, such that it returns both itself and 
it's child elements.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Element::field>, 
L<HTML::FormFu::Element::multi>, L<HTML::FormFu::Element::block>, 
L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
