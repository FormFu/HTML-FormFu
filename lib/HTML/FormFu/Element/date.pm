package HTML::FormFu::Element::date;

use strict;
use warnings;
use base 'HTML::FormFu::Element::multi', 'HTML::FormFu::Element::field';
use Class::C3;

use DateTime::Format::Builder;
use HTML::FormFu::Util qw/ _get_elements /;

__PACKAGE__->mk_accessors(qw/
    day_name month_name year_name
    months years year year_less year_plus 
    strftime
/);
#    day_default month_default year_default
#    day_options day_values day_value_range 
#    month_options month_values month_value_range 
#    year_options year_values year_value_range 

sub new {
    my $self = shift->next::method(@_);

    $self->is_field(0);
    $self->strftime("%d-%m-%Y") if !defined $self->strftime;
    $self->year_less(0)         if !defined $self->year_less;
    $self->year_plus(10)        if !defined $self->year_plus;

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

    my @months = defined $self->months
               ? @{ $self->months }
               : qw/ Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec /;

    my $year = defined $self->year
             ? $self->year
             : (localtime(time))[5] + 1900;

    my @years = defined $self->years
              ? @{ $self->years }
              : ( $year - $self->year_less ) .. ( $year + $self->year_plus );

    $self->element({
        type => 'select',
        name => $day_name,
        values => [1..31],
        });

    $self->element({
        type => 'select',
        name => $month_name,
        options => [ map { [ $_+1, $months[$_] ] } 0..11 ],
        });

    $self->element({
        type => 'select',
        name => $year_name,
        values => \@years,
        });
    
    return;
}

sub process {
    my $self = shift;
    
    $self->_add_elements;
    
    my $query = $self->form->query;
    
    my $day_name = defined $self->day_name
                 ? $self->day_name
                 : sprintf "%s.day", $self->name;

    my $month_name = defined $self->month_name
                   ? $self->month_name
                   : sprintf "%s.month", $self->name;

    my $year_name = defined $self->year_name
                  ? $self->year_name
                  : sprintf "%s.year", $self->name;
    
    if ( defined $query->{$day_name}
      && defined $query->{$month_name}
      && defined $query->{$year_name} )
    {
        my $dt = DateTime->new(
            day   => $query->{$day_name},
            month => $query->{$month_name},
            year  => $query->{$year_name},
        );
        
        $query->{ $self->name } = $dt->strftime( $self->strftime );
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

The format the date is returned by L<HTML::FormFu/params>.

=head2 months

Arguments: \@months

A list of month names used for the month menu.

If not set, the English short names are used (Jan, Feb, etc.).

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

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Element::input>, 
L<HTML::FormFu::Element::field>, L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
