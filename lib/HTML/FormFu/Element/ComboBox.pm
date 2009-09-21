package HTML::FormFu::Element::ComboBox;
use strict;
use base 'HTML::FormFu::Element::Multi';
use Class::C3;

use HTML::FormFu::Element::_Group qw( _process_options_from_model );
use HTML::FormFu::Util qw( _filter_components _parse_args );
use List::MoreUtils qw( any );

our @DEFER_TO_SELECT = qw(
    empty_first
    empty_first_label
    values
    value_range
);

__PACKAGE__->mk_accessors(
    @DEFER_TO_SELECT,
    qw(
        select
        text
        ) );

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

    no strict 'refs';

    *{$name} = $sub;
}

sub new {
    my $self = shift->next::method(@_);

    $self->multi_value(1);
    $self->empty_first(1);

    $self->select( { type => '_MultiSelect', } );

    $self->text( { type => '_MultiText', } );

    return $self;
}

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
            type => $select->{type},
            name => $select_name,
        } );

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
            type => $text->{type},
            name => $text_name,
        } );

    if ( defined( my $default = $text->{default} ) ) {
        $text_element->default($default);
    }

    return;
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

    return $self->next::method(@args);
}

sub process_input {
    my ( $self, $input ) = @_;

    my $select_name = _build_field_name( $self, 'select' );
    my $text_name   = _build_field_name( $self, 'text' );

    $select_name = $self->get_element( { name => $select_name } )->nested_name;
    $text_name   = $self->get_element( { name => $text_name } )->nested_name;

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

HTML::FormFu::Element::ComboBox - Select / Text hybrid

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

See L<HTML::FormFu::Element::_Group/options> for details.

=head2 values

See L<HTML::FormFu::Element::_Group/values> for details.

=head2 value_range

See L<HTML::FormFu::Element::_Group/value_range> for details.

=head2 empty_first

See L<HTML::FormFu::Element::Select/empty_first> for details.

=head2 empty_first_label

See L<HTML::FormFu::Element::Select/empty_first_label> for details.

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
L<filter/filters|HTML::FormFu/filters>, 
L<constraint/constraints|HTML::FormFu/constraints>, 
L<inflator/inflators|HTML::FormFu/inflators>, 
L<validator/validators|HTML::FormFu/validators> and 
L<transformer/transformers|HTML::FormFu/transformers> is more like that of 
a L<field element|HTML::FormFu::Element::_Field>, meaning all processors are 
added directly to the date element, not to its child elements.

This element's L<get_elements|HTML::FormFu/get_elements> and 
L<get_all_elements|HTML::FormFu/get_all_elements> are inherited from 
L<HTML::FormFu::Element::Block>, and so have the same behaviour. However, it 
overrides the C<get_fields> method, such that it returns both itself and 
its child elements.

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
