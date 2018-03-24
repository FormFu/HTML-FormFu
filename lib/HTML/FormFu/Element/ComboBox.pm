use strict;
package HTML::FormFu::Element::ComboBox;
# ABSTRACT: Select / Text hybrid


use Moose;
use MooseX::Attribute::Chained;
extends 'HTML::FormFu::Element::Multi';

with 'HTML::FormFu::Role::Element::ProcessOptionsFromModel';

use HTML::FormFu::Util qw( _filter_components _parse_args );
use List::Util 1.33 qw( any );
use Moose::Util qw( apply_all_roles );

our @DEFER_TO_SELECT = qw(
    empty_first
    empty_first_label
    values
    value_range
);

for my $name (@DEFER_TO_SELECT) {
    has $name => ( is => 'rw', traits => ['Chained'] );
}

has select => ( is => 'rw', traits => ['Chained'], default => sub { {} } );
has text   => ( is => 'rw', traits => ['Chained'], default => sub { {} } );

*default = \&value;

## build get_Xs methods
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

    ## no critic (ProhibitNoStrict);
    no strict 'refs';

    *{$name} = $sub;
}

after BUILD => sub {
    my ( $self, $args ) = @_;

    $self->multi_value(1);
    $self->empty_first(1);

    return;
};

sub options {
    my ( $self, @args ) = @_;

    if (@args) {
        $self->{options} = @args == 1 ? $args[0] : \@args;

        return $self;
    }
    else {

        # we're being called as a getter!
        # are the child elements made yet?

        if ( !@{ $self->_elements } ) {

            # need to build the children, so we can return the select options
            $self->_add_elements;
        }

        return $self->_elements->[0]->options;
    }
}

sub value {
    my ( $self, $value ) = @_;

    if ( @_ > 1 ) {
        $self->{value} = $value;

        # if we're already built - i.e. process() has been called,
        # call default() on our children

        if ( @{ $self->_elements } ) {
            $self->_combobox_defaults;

            $self->_elements->[0]->default( $self->select->{default} );
            $self->_elements->[1]->default( $self->text->{default} );
        }

        return $self;
    }

    return $self->{value};
}

sub _add_elements {
    my ($self) = @_;

    $self->_elements( [] );

    $self->_add_select;
    $self->_add_text;

    $self->_combobox_defaults;

    return;
}

sub _combobox_defaults {
    my ($self) = @_;

    if ( defined( my $default = $self->default ) ) {

        if ( !$self->form->submitted || $self->render_processed_value ) {
            for my $deflator ( @{ $self->_deflators } ) {
                $default = $deflator->process($default);
            }
        }

        my $select_options = $self->_elements->[0]->options;

        if ( $default ne ''
            && any { $_->{value} eq $default } @$select_options )
        {
            $self->select->{default} = $default;
            $self->text->{default}   = undef;
        }
        else {
            $self->select->{default} = undef;
            $self->text->{default}   = $default;
        }
    }

    return;
}

sub _add_select {
    my ($self) = @_;

    my $select = $self->select;

    my $select_name = _build_field_name( $self, 'select' );

    my $select_element = $self->element( {
            type => 'Select',
            name => $select_name,
        } );

    apply_all_roles( $select_element,
        'HTML::FormFu::Role::Element::MultiElement' );

    for my $method (@DEFER_TO_SELECT) {
        if ( defined( my $value = $self->$method ) ) {
            $select_element->$method($value);
        }
    }

    if ( !@{ $select_element->options } ) {

        # we need to access the hashkey directly,
        # otherwise we'll have a loop
        $select_element->options( $self->{options} );
    }

    if ( defined( my $default = $select->{default} ) ) {
        $select_element->default($default);
    }

    return;
}

sub _add_text {
    my ($self) = @_;

    my $text = $self->text;

    my $text_name = _build_field_name( $self, 'text' );

    my $text_element = $self->element( {
            type => 'Text',
            name => $text_name,
        } );

    apply_all_roles( $text_element,
        'HTML::FormFu::Role::Element::MultiElement' );

    if ( defined( my $default = $text->{default} ) ) {
        $text_element->default($default);
    }

    return;
}

sub get_select_field_nested_name {
    my ($self) = @_;

    my $select_name = _build_field_name( $self, 'select' );

    return $self->get_element( { name => $select_name } )->nested_name;
}

sub get_text_field_nested_name {
    my ($self) = @_;

    my $text_name = _build_field_name( $self, 'text' );

    return $self->get_element( { name => $text_name } )->nested_name;
}

sub _build_field_name {
    my ( $self, $type ) = @_;

    my $options = $self->$type;
    my $name;

    if ( defined( my $default_name = $options->{name} ) ) {
        $name = $default_name;
    }
    else {
        $name = sprintf "%s_%s", $self->name, $type;
    }

    return $name;
}

sub process {
    my ( $self, @args ) = @_;

    $self->_process_options_from_model;

    $self->_add_elements;

    return $self->SUPER::process(@args);
}

sub process_input {
    my ( $self, $input ) = @_;

    my $select_name = $self->get_select_field_nested_name;
    my $text_name   = $self->get_text_field_nested_name;

    my $select_value = $self->get_nested_hash_value( $input, $select_name );
    my $text_value   = $self->get_nested_hash_value( $input, $text_name );

    if ( defined $text_value && length $text_value ) {
        $self->set_nested_hash_value( $input, $self->nested_name, $text_value,
        );
    }
    elsif ( defined $select_value && length $select_value ) {
        $self->set_nested_hash_value( $input, $self->nested_name, $select_value,
        );
    }

    return $self->SUPER::process_input($input);
}

sub render_data {
    return shift->render_data_non_recursive(@_);
}

sub render_data_non_recursive {
    my ( $self, $args ) = @_;

    my $render = $self->SUPER::render_data_non_recursive( {
            elements => [ map { $_->render_data } @{ $self->_elements } ],
            $args ? %$args : (),
        } );

    return $render;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SYNOPSIS

    ---
    elements:
      - type: ComboBox
        name: answer
        label: 'Select yes or no, or write an alternative:'
        values:
          - yes
          - no


=head1 DESCRIPTION

Creates a L<multi|HTML::FormFu::Element::Multi> element containing a Select
field and a Text field.

A ComboBox element named C<foo> would result in a Select menu named
C<foo_select> and a Text field named C<foo_text>. The names can instead be
overridden by the C<name> value in L</select> and L</text>.

If a value is submitted for the Text field, this will be used in preference
to any submitted value for the Select menu.

You can access the submitted value by using the ComboBox's name:

    my $value = $form->param_value('foo');

=head1 METHODS

=head2 default

If the value matches one of the Select menu's options, that options will be
selected. Otherwise, the Text field will use the value as its default.

=head2 options

See L<HTML::FormFu::Role::Element::Group/options> for details.

=head2 values

See L<HTML::FormFu::Role::Element::Group/values> for details.

=head2 value_range

See L<HTML::FormFu::Role::Element::Group/value_range> for details.

=head2 empty_first

See L<HTML::FormFu::Role::Element::Group/empty_first> for details.

=head2 empty_first_label

See L<HTML::FormFu::Role::Element::Group/empty_first_label> for details.

=head2 select

Arguments: \%setting

Set values effecting the Select menu. Known keys are:

=head3 name

Override the auto-generated name of the select menu.

=head2 text

Arguments: \%setting

Set values effecting the Text field. Known keys are:

=head3 name

Override the auto-generated name of the select menu.

=head1 CAVEATS

Although this element inherits from L<HTML::FormFu::Element::Block>, its
behaviour for the methods
L<filterE<sol>filters|HTML::FormFu/filters>,
L<constraintE<sol>constraints|HTML::FormFu/constraints>,
L<inflatorE<sol>inflators|HTML::FormFu/inflators>,
L<validatorE<sol>validators|HTML::FormFu/validators> and
L<transformerE<sol>transformers|HTML::FormFu/transformers> is more like that of
a L<field element|HTML::FormFu::Role::Element::Field>, meaning all processors are
added directly to the date element, not to its child elements.

This element's L<get_elements|HTML::FormFu/get_elements> and
L<get_all_elements|HTML::FormFu/get_all_elements> are inherited from
L<HTML::FormFu::Element::Block>, and so have the same behaviour. However, it
overrides the C<get_fields|HTML::FormFu/get_fields> method, such that it
returns both itself and its child elements.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from
L<HTML::FormFu::Element::Multi>,
L<HTML::FormFu::Element::Block>,
L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
