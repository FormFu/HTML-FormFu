package HTML::FormFu::Element;
use strict;
use base 'HTML::FormFu::base';
use Class::C3;

use HTML::FormFu::Attribute qw/ mk_attrs mk_attr_accessors
    mk_output_accessors mk_inherited_accessors mk_accessors
    mk_inherited_merging_accessors /;
use HTML::FormFu::ObjectUtil qw/
    :FORM_AND_ELEMENT
    load_config_file populate form stash parent /;
use HTML::FormFu::Util qw/ require_class xml_escape /;
use Scalar::Util qw/ refaddr weaken /;
use Storable qw( dclone );
use Carp qw/ croak /;

use overload
    'eq' => sub { refaddr $_[0] eq refaddr $_[1] },
    'ne' => sub { refaddr $_[0] ne refaddr $_[1] },
    '==' => sub { refaddr $_[0] eq refaddr $_[1] },
    '!=' => sub { refaddr $_[0] ne refaddr $_[1] },
    '""' => sub { return shift->render },
    bool => sub {1},
    fallback => 1;

__PACKAGE__->mk_attrs(qw/ attributes /);

__PACKAGE__->mk_attr_accessors(qw/ id /);

__PACKAGE__->mk_accessors(
    qw/
        name type filename is_field is_block is_repeatable /
);

__PACKAGE__->mk_inherited_accessors(qw/ tt_args render_method /);

__PACKAGE__->mk_inherited_merging_accessors(qw/ config_callback /);

sub new {
    my $class = shift;

    my %attrs;
    eval { %attrs = %{ $_[0] } if @_ };
    croak "attributes argument must be a hashref" if $@;

    my $self = bless {}, $class;

    $self->attributes( {} );
    $self->stash(      {} );

    if ( exists $attrs{parent} ) {
        $self->parent( delete $attrs{parent} );
    }

    $self->populate( \%attrs );

    return $self;
}

sub db {
    my $self = shift;

    warn "db() method deprecated and is provided for compatibilty only: "
        . "use model_config() instead as this will be removed\n";

    if (@_) {
        my $args = shift;

        $self->model_config = {}
            if !$self->model_config;

        my $conf = $self->model_config;

        for ( keys %$args ) {
            $conf->{$_} = $args->{$_};
        }
    }

    return $self->model_config;
}

sub setup { }

sub get_elements { [] }

sub get_element { }

sub get_all_elements { [] }

sub get_all_element { }

sub get_fields { [] }

sub get_field { }

sub get_deflators { [] }

sub get_filters { [] }

sub get_constraints { [] }

sub get_inflators { [] }

sub get_validators { [] }

sub get_transformers { [] }

sub get_errors { [] }

sub clear_errors { }

sub process { }

sub post_process { }

sub prepare_id { }

sub prepare_attrs { }

sub get_output_processors {
    my $self = shift;

    return $self->form->get_output_processors(@_);
}

sub get_output_processor {
    my $self = shift;

    return $self->form->get_output_processor(@_);
}

sub clone {
    my ($self) = @_;

    my %new = %$self;

    $new{tt_args} = dclone $self->{tt_args}
        if $self->{tt_args};

    $new{attributes}   = dclone $self->attributes;
    $new{model_config} = dclone $self->model_config;

    return bless \%new, ref $self;
}

sub render_data {
    return shift->render_data_non_recursive(@_);
}

sub render_data_non_recursive {
    my $self = shift;

    my %render = (
        name       => xml_escape( $self->name ),
        attributes => xml_escape( $self->attributes ),
        type       => $self->type,
        filename   => $self->filename,
        is_field   => $self->is_field,
        stash      => $self->stash,
        parent     => $self->parent,
        form       => sub { return shift->{parent}->form },
        object     => $self,
        @_ ? %{ $_[0] } : () );

    weaken( $render{parent} );

    $self->prepare_id( \%render );

    $self->prepare_attrs( \%render );

    return \%render;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element - Element Base Class

=head1 SYNOPSIS

    ---
    elements:
      - type: Text
        name: username
        constraints:
          - type: Required
      
      - type: Password
        name: password
        constraints:
          - type: Required
          - type: Equal
            others: repeat-password
      
      - type: Password
        name: repeat-password
      
      - type: Submit

=head1 DESCRIPTION

Elements are the basic building block of all forms. Elements may be logical 
form-fields, blocks such as C<div>s and C<fieldset>s, non-blocks such as 
C<hr>s and other special elements such as tables.

For simple, automatic handling of fieldsets see the 
L<HTML::FormFu/auto_fieldset> setting.

See L<HTML::FormFu/deflators> for details of 
L<Deflators|HTML::FormFu::Deflator>.

See L<HTML::FormFu/FORM LOGIC AND VALIDATION> for details of 
L<Filters|HTML::FormFu::Filter>, 
L<Constraints|HTML::FormFu::Constraint>, 
L<Inflators|HTML::FormFu::Inflator>, 
L<Validators|HTML::FormFu::Validator> and 
L<Transformers|HTML::FormFu::Transformer>.

=head1 METHODS

=head2 name

For L<field|HTML::FormFu::Element::_Field> element, this value is used as 
the C<name> attribute which the field's value is associated with.

For all elements, the L</name> value can be useful for identifying and 
retrieving specific elements.

=head2 is_field

Return Value: boolean

Returns C<true> or C<false> depending on whether the element is a logical 
form-field.

This is used by L<HTML::FormFu/get_fields>.

=head1 BUILDING AN ELEMENT

=head2 load_config_file

Arguments: $filename

Arguments: \@filenames

Populate an element using a config file:

    ---
    elements:
      - type: Block
        load_config_file: 'elements.yml'

See L<HTML::FormFu/load_config_file> for further details.

=head2 config_callback

See L<HTML::FormFu/config_callback> for details.

=head2 populate

See L<HTML::FormFu/populate> for details.

=head2 stash

See L<HTML::FormFu/stash> for details.

=head2 type

Returns the C<type> argument originally used to create the element.

=head1 CHANGING DEFAULT BEHAVIOUR

=head2 render_processed_value

See L<HTML::FormFu/render_processed_value> for details.

=head2 force_errors

See L<HTML::FormFu/force_errors> for details.

=head1 ELEMENT ATTRIBUTES

See specific element types for which tag attributes are added to.

=head2 attributes

=head2 attrs

Arguments: [%attributes]

Arguments: [\%attributes]

Return Value: $form

See L<HTML::FormFu/attributes> for details.

L</attrs> is an alias for L</attributes>.

=head2 attributes_xml

=head2 attrs_xml

See L<HTML::FormFu/attributes_xml> for details.

L</attrs_xml> is an alias for L</attributes_xml>.

=head2 add_attributes

=head2 add_attrs

Arguments: [%attributes]

Arguments: [\%attributes]

Return Value: $form

See L<HTML::FormFu/add_attributes> for details.

L</add_attrs> is an alias for L</add_attributes>.

=head2 add_attributes_xml

=head2 add_attrs_xml

See L<HTML::FormFu/add_attributes_xml> for details.

L</add_attrs_xml> is an alias for L</add_attributes_xml>.

=head2 del_attributes

=head2 del_attrs

Arguments: [%attributes]

Arguments: [\%attributes]

Return Value: $form

See L<HTML::FormFu/del_attributes> for details.

L</del_attrs> is an alias for L</del_attributes>.

=head2 del_attributes_xml

=head2 del_attrs_xml

See L<HTML::FormFu/del_attributes_xml> for details.

L</del_attrs_xml> is an alias for L</del_attributes_xml>.

The following methods are shortcuts for accessing L<"/attributes"> keys.

=head2 id

Arguments: [$id]

Return Value: $id

Get or set the element's DOM id.

Default Value: none

=head1 MODEL / DATABASE INTERACTION

See L<HTML::FormFu::Model> for further details and available models.

=head2 model_config

Arguments: \%config

=head1 RENDERING

=head2 filename

This value identifies which template file should be used by 
L</render> to render the element.

=head2 prepare_id

Arguments: $render

See L<HTML::FormFu::Element::_Field/prepare_id> for details.

=head2 prepare_attrs

Arguments: $render

See L<HTML::FormFu::Element::_Field/prepare_attrs> for details.

=head2 render

Return Value: $string

=head2 INTROSPECTION

=head2 parent

Returns the L<block element|HTML::FormFu::Element> or L<form|HTML::FormFu> 
object that this element is attached to.

=head2 form

Returns the L<HTML::FormFu> object that the constraint's field is attached 
to.

=head2 clone

See L<HTML::FormFu/clone> for details.

=head1 ADVANCED CUSTOMISATION

=head2 tt_args

See L<HTML::FormFu/tt_args> for details.

=head2 render_method

See L<HTML::FormFu/render_method> for details.

=head1 CORE FORM FIELDS

=over

=item L<HTML::FormFu::Element::Button>

=item L<HTML::FormFu::Element::Checkbox>

=item L<HTML::FormFu::Element::Checkboxgroup>

=item L<HTML::FormFu::Element::ContentButton>

=item L<HTML::FormFu::Element::Date>

=item L<HTML::FormFu::Element::File>

=item L<HTML::FormFu::Element::Hidden>

=item L<HTML::FormFu::Element::Image>

=item L<HTML::FormFu::Element::Password>

=item L<HTML::FormFu::Element::Radio>

=item L<HTML::FormFu::Element::Radiogroup>

=item L<HTML::FormFu::Element::Reset>

=item L<HTML::FormFu::Element::Select>

=item L<HTML::FormFu::Element::Submit>

=item L<HTML::FormFu::Element::Textarea>

=item L<HTML::FormFu::Element::Text>

=back

=head1 OTHER CORE ELEMENTS

=over

=item L<HTML::FormFu::Element::Blank>

=item L<HTML::FormFu::Element::Block>

=item L<HTML::FormFu::Element::Fieldset>

=item L<HTML::FormFu::Element::Hr>

=item L<HTML::FormFu::Element::Multi>

=item L<HTML::FormFu::Element::Repeatable>

=item L<HTML::FormFu::Element::SimpleTable>

=item L<HTML::FormFu::Element::Src>

=back

=head1 ELEMENT BASE CLASSES

The following are base classes for other elements, and generally needn't be 
used directly.

=over

=item L<HTML::FormFu::Element::_Field>

=item L<HTML::FormFu::Element::_Group>

=item L<HTML::FormFu::Element::_Input>

=item L<HTML::FormFu::Element::NonBlock>

=back

=head1 DEPRECATED METHODS

=head2 db

Is deprecated and provided only for backwards compatability. Will be removed
at some point in the future.

Use L</model_config> instead.

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
