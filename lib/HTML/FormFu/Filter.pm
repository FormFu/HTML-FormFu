package HTML::FormFu::Filter;

use strict;
use warnings;
use base 'Class::Accessor::Chained::Fast';

use HTML::FormFu::ObjectUtil qw( populate form name );
use Carp qw( croak );

__PACKAGE__->mk_accessors(qw/ parent type localize_args /);

sub new {
    my $class = shift;

    my %attrs;
    eval { %attrs = %{ $_[0] } if @_ };
    croak "attributes argument must be a hashref" if $@;

    my $self = bless {}, $class;

    $self->populate( \%attrs );

    return $self;
}

sub process {
    my ( $self, $result, $params ) = @_;

    my $name = $self->name;

    # don't run filters on invalid input
    return if $result->has_errors($name);

    my $values = $params->{$name};
    if ( ref $values eq 'ARRAY' ) {
        $params->{$name} = [ map { $self->filter( $_, $params ); } @$values ];
    }
    else {
        $params->{$name} = $self->filter( $values, $params );
    }

    return;
}

sub clone {
    my ( $self ) = @_;
    
    my %new = %$self;
    
    return bless \%new, ref $self;
}

1;

__END__

=head1 NAME

HTML::FormFu::Filter - Filter Base Class

=head1 SYNOPSIS

    ---
    elements: 
      - type: text
        name: foo
        filters:
          - type: Encode
            candidates:
              - utf8
              - Hebrew
      - type: text
        name: bar
        filters: 
          - LowerCase
          - Encode
    filters: 
      - TrimEdges

=head1 DESCRIPTION

C<filters()> and C<filter> can be called on any L<form|HTML::FormFu>, 
L<block element|HTML::FormFu::Element::block> (includes fieldsets) or 
L<field element|HTML::FormFu::Element::field>.

If called on a field element, no C<name> argument should be passed.

If called on a L<form|HTML::FormFu> or 
L<block element|HTML::FormFu::Element::block>, if no C<name> argument is 
provided, a new filter is created for and added to every field on that form 
or block.

See L<HTML::FormFu/"FORM LOGIC AND VALIDATION"> for further details.

=head1 METHODS

=head2 type

Returns the C<type> argument originally used to create the filter.

=head2 localise_args

Provide arguments that should be passed to L<localize|HTML::FormFu/localize> 
to replace C<[_1]>, C<[_2]>, etc. in the localized string.

=head2 parent

Returns the L<HTML::FormFu::Element::field> object that the filter is 
associated with.

=head2 form

Returns the L<HTML::FormFu> object that the filter's field is attached to.

=head2 name

Shorthand for C<< $filter->parent->name >>

=head1 CORE FILTERS

=over

=item L<HTML::FormFu::Filter::Callback>

=item L<HTML::FormFu::Filter::Encode>

=item L<HTML::FormFu::Filter::HTMLEscape>

=item L<HTML::FormFu::Filter::HTMLScrubber>

=item L<HTML::FormFu::Filter::LowerCase>

=item L<HTML::FormFu::Filter::NonNumeric>

=item L<HTML::FormFu::Filter::Regex>

=item L<HTML::FormFu::Filter::TrimEdges>

=item L<HTML::FormFu::Filter::UpperCase>

=item L<HTML::FormFu::Filter::Whitespace>

=back

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

Based on the original source code of L<HTML::Widget::Filter>, by 
Sebastian Riedel.

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
