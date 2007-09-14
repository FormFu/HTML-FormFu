package HTML::FormFu::Element::SimpleTable;

use strict;
use base 'HTML::FormFu::Element::Block';
use Class::C3;

use HTML::FormFu::Util qw/ append_xml_attribute /;
use Carp qw/ croak /;

__PACKAGE__->mk_accessors(qw/ odd_class even_class /);

sub new {
    my $self = shift->next::method(@_);

    $self->tag('table');

    return $self;
}

sub headers {
    my ( $self, $headers ) = @_;

    eval { my @foo = @$headers; };
    croak "headers must be passed as an array-ref" if $@;

    # save any elements already added
    my @original_rows = @{ $self->_elements };
    $self->_elements( [] );

    my $header_row = $self->element('Block');
    $header_row->tag('tr');

    for my $text (@$headers) {
        my $th = $header_row->element('Block');
        $th->tag('th');
        $th->content($text);
    }

    if (@original_rows) {
        push @{ $self->_elements }, @original_rows;
    }

    return $self;
}

sub rows {
    my ( $self, $rows ) = @_;

    croak "too many arguments" if @_ > 2;

    eval { my @foo = @$rows; };
    croak "rows must be passed as an array-ref" if $@;

    for my $cells (@$rows) {
        my @cells;
        eval { @cells = @$cells; };
        croak "each row must be an array-ref" if $@;

        my $row = $self->element('Block');
        $row->tag('tr');

        for my $cell (@cells) {
            my $td = $row->element('Block');
            $td->tag('td');
            $td->element($cell);
        }
    }

    return $self;
}

sub render {
    my $self = shift;

    my $odd  = $self->odd_class;
    my $even = $self->even_class;
    my $i    = 1;

    for my $row ( @{ $self->get_elements } ) {
        my $first_cell = $row->get_element;

        if ( $i == 1 && $first_cell->tag eq 'th' ) {

            # skip the header row
            next;
        }

        if ( $i % 2 ) {
            $row->attributes( { class => $odd } )
                if defined $odd;
        }
        else {
            $row->attributes( { class => $even } )
                if defined $even;
        }
        $i++;
    }

    my $render = $self->next::method(@_);

    append_xml_attribute( $render->attributes, 'class', lc $self->type );

    return $render;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::SimpleTable

=head1 SYNOPSIS

The following is yaml markup for a table consisting of a header row 
containing 2 C<th> cells, and a further 2 rows, each containing 2 C<td> 
cells. 

    type: SimpleTable
    headers: 
      - One
      - Two
    rows: 
      - 
        - type: Input
          name: one_a
        - type: Input
          name: two_a
      - 
        - type: Input
          name: one_b
        - type: Input
          name: two_b

=head1 DESCRIPTION

Sometimes you just really need to use a table to display some fields in a 
grid format.

As it's name suggests, this is a compromise between power and simplicity. 
If you want more control of the markup, you'll probably just have to revert 
to using nested L<block's|HTML::FormFu::Element::_Block>, setting the tags 
to table, tr, td, etc. and adding the cell contents as elements.

=head1 METHODS

=head2 headers

Input Value: \@headers

L</headers> accepts an arrayref of strings. Each string is xml-escaped and 
inserted into a new header cell.

=head2 rows

Input Value: \@rows

L</rows> accepts an array-ref, each item representing a new row. Each row 
should be comprised of an array-ref, each item representing a table cell.

Each cell item should be appropriate for passing to L<HTML::FormFu/element>; 
so either a single element's definition, or an array-ref of element 
definitions.

=head2 odd_class

Input Value: $string

The supplied string will be used as the class-name for each odd-numbered row 
(not counting any header row).

=head2 even_class

Input Value: $string

The supplied string will be used as the class-name for each even-numbered row 
(not counting any header row).

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::_Block>, 
L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
