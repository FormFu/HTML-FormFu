package HTML::FormFu::Filter;
use Moose;
use MooseX::Attribute::Chained;

with 'HTML::FormFu::Role::NestedHashUtils',
     'HTML::FormFu::Role::HasParent',
     'HTML::FormFu::Role::Populate';

use HTML::FormFu::Attribute qw( mk_inherited_accessors );
use HTML::FormFu::ObjectUtil qw(
    form name parent nested_name nested_names );
use Carp qw( croak );

has type => ( is => 'rw', traits  => ['Chained'] );

has localize_args => ( is => 'rw', traits  => ['Chained'] );

sub process {
    my ( $self, $result, $params ) = @_;

    my $name = $self->nested_name;
    my $value = $self->get_nested_hash_value( $params, $name );

    my $filtered;

    if ( ref $value eq 'ARRAY' ) {
        $filtered = [ map { $self->filter( $_, $params ) } @$value ];
    }
    else {
        $filtered = $self->filter( $value, $params );
    }

    $self->set_nested_hash_value( $params, $name, $filtered );

    return;
}

sub clone {
    my ($self) = @_;

    my %new = %$self;

    return bless \%new, ref $self;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::Filter - Filter Base Class

=head1 SYNOPSIS

    ---
    elements: 
      - type: Text
        name: foo
        filters:
          - type: Encode
            candidates:
              - utf8
              - Hebrew
      - type: Text
        name: bar
        filters: 
          - LowerCase
          - Encode
    filters: 
      - TrimEdges

=head1 DESCRIPTION

C<filters()> and C<filter> can be called on any L<form|HTML::FormFu>, 
L<block element|HTML::FormFu::Element::Block> (includes fieldsets) or 
L<field element|HTML::FormFu::Element::_Field>.

If called on a field element, no C<name> argument should be passed.

If called on a L<form|HTML::FormFu> or 
L<block element|HTML::FormFu::Element::Block>, if no C<name> argument is 
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

Returns the L<HTML::FormFu::Element::_Field> object that the filter is 
associated with.

=head2 get_parent

Arguments: \%options

Traverses the parent hierarchy, returning the first parent that matches the
supplied options.

=head2 form

Returns the L<HTML::FormFu> object that the filter's field is attached to.

=head2 name

Shorthand for C<< $filter->parent->name >>

=head1 CORE FILTERS

=over

=item L<HTML::FormFu::Filter::Callback>

=item L<HTML::FormFu::Filter::CompoundJoin>

=item L<HTML::FormFu::Filter::CompoundSprintf>

=item L<HTML::FormFu::Filter::CopyValue>

=item L<HTML::FormFu::Filter::Default>

=item L<HTML::FormFu::Filter::Encode>

=item L<HTML::FormFu::Filter::FormatNumber>

=item L<HTML::FormFu::Filter::HTMLEscape>

=item L<HTML::FormFu::Filter::HTMLScrubber>

=item L<HTML::FormFu::Filter::LowerCase>

=item L<HTML::FormFu::Filter::NonNumeric>

=item L<HTML::FormFu::Filter::Regex>

=item L<HTML::FormFu::Filter::Split>

=item L<HTML::FormFu::Filter::TrimEdges>

=item L<HTML::FormFu::Filter::UpperCase>

=item L<HTML::FormFu::Filter::Whitespace>

=back

=head1 FILTER BASE CLASSES

The following are base classes for other filters, and generally needn't be 
used directly.

=over

=item L<HTML::FormFu::Filter::_Compound>

=back

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

Based on the original source code of L<HTML::Widget::Filter>, by 
Sebastian Riedel.

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
