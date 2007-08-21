package HTML::FormFu::Element;

use strict;
use warnings;
use base 'Class::Accessor::Chained::Fast';
use Class::C3;

use HTML::FormFu::Accessor qw( mk_output_accessors mk_inherited_accessors
    mk_inherited_merging_accessors );
use HTML::FormFu::Attribute qw/ mk_attrs mk_attr_accessors /;
use HTML::FormFu::ObjectUtil qw/ load_config_file _render_class
    populate form stash /;
use HTML::FormFu::Util qw/ _parse_args require_class xml_escape /;
use Scalar::Util qw/ refaddr /;
use Storable qw( dclone );
use Carp qw/ croak /;

use overload
    'eq' => sub { refaddr $_[0] eq refaddr $_[1] },
    '==' => sub { refaddr $_[0] eq refaddr $_[1] },
    '""'     => sub { return shift->render },
    bool     => sub {1},
    fallback => 1;

__PACKAGE__->mk_attrs(qw/ attributes /);

__PACKAGE__->mk_attr_accessors(qw/ id /);

__PACKAGE__->mk_accessors(
    qw/
        parent name type filename multi_filename is_field
        render_class_suffix /
);

__PACKAGE__->mk_inherited_accessors(
    qw/ render_class render_class_prefix render_class_args
        render_method /
);

__PACKAGE__->mk_inherited_merging_accessors(qw/ config_callback /);

sub new {
    my $class = shift;

    my %attrs;
    eval { %attrs = %{ $_[0] } if @_ };
    croak "attributes argument must be a hashref" if $@;

    my $self = bless {}, $class;

    $self->attributes( {} );
    $self->stash(      {} );

    $self->populate( \%attrs );

    return $self;
}

sub setup { }

sub get_elements { [] }

sub get_element { }

sub get_all_elements { [] }

sub get_all_element { }

sub get_fields { [] }

sub get_field { }

sub get_deflators { [] }

sub get_deflator { }

sub get_filters { [] }

sub get_filter { }

sub get_constraints { [] }

sub get_constraint { }

sub get_inflators { [] }

sub get_inflator { }

sub get_validators { [] }

sub get_validator { }

sub get_transformers { [] }

sub get_transformer { }

sub get_errors { [] }

sub clear_errors { }

sub process { }

sub prepare_id { }

sub prepare_attrs { }

sub clone {
    my ($self) = @_;

    my %new = %$self;

    $new{render_class_args} = dclone $self->{render_class_args}
        if $self->{render_class_args};

    $new{attributes} = dclone $self->attributes;

    return bless \%new, ref $self;
}

sub render {
    my $self = shift;

    my $class = $self->_render_class('Element');
    require_class($class);

    my $render = $class->new( {
            name                => xml_escape( $self->name ),
            attributes          => xml_escape( $self->attributes ),
            render_class_args   => dclone( $self->render_class_args ),
            type                => $self->type,
            render_class_suffix => $self->render_class_suffix,
            render_method       => $self->render_method,
            filename            => $self->filename,
            multi_filename      => $self->multi_filename,
            is_field            => $self->is_field,
            stash               => $self->stash,
            parent              => $self,
            @_ ? %{ $_[0] } : () } );

    $self->prepare_id($render);

    $self->prepare_attrs($render);

    return $render;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element - Element Base Class

=head1 SYNOPSIS

    ---
    elements:
      - type: text
        name: username
        constraints:
          - type: Required
      
      - type: password
        name: password
        constraints:
          - type: Required
          - type: Equal
            others: repeat-password
      
      - type: password
        name: repeat-password
      
      - type: submit

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

See L<HTML::FormFu/load_config_file> for details.

=head2 config_callback

See L<HTML::FormFu/config_callback> for details.

=head2 populate

See L<HTML::FormFu/populate> for details.

=head2 stash

See L<HTML::FormFu/stash> for details.

=head2 type

Returns the C<type> argument originally used to create the element.

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

=head1 RENDERING

=head2 filename

This value identifies which template file should be used by 
L<HTML::FormFu::Render::base/xhtml> to render the element.

=head2 multi_filename

This value identifies which template file should be used to render the 
element when the element is within a 
L<multi element|HTML::FormFu::Element::Multi>.

This value is generally either C<multi_ltr> or C<multi_rtl> depending on 
whether the field and label should be displayed from left-to-right or 
right-to-left.

=head2 prepare_id

Arguments: $render

See L<HTML::FormFu::Element::_Field/prepare_id> for details.

=head2 prepare_attrs

Arguments: $render

See L<HTML::FormFu::Element::_Field/prepare_attrs> for details.

=head2 render

Return Value: $render_object

Returns a C<$render> object which can either be printed, or used for more 
advanced custom rendering.

Using an C<$element> object in string context (for example, printing it) 
automatically calls L</render>.

The default base-class of the returned render object is 
L<HTML::FormFu::Render::Element>.

=head2 INTROSPECTION

=head2 parent

Returns the L<HTML::FormFu::Element> or L<HTML::FormFu> object that this 
element is attached to.

=head2 form

Returns the L<HTML::FormFu> object that this element is attached to.

=head2 clone

See L<HTML::FormFu/clone> for details.

=head1 ADVANCED CUSTOMISATION

=head2 render_class

See L<HTML::FormFu/render_class> for details.

=head2 render_class_prefix

See L<HTML::FormFu/render_class_prefix> for details.

=head2 render_class_suffix

See L<HTML::FormFu/render_class_suffix> for details.

=head2 render_class_args

See L<HTML::FormFu/render_class_args> for details.

=head2 render_method

See L<HTML::FormFu/render_method> for details.

=head1 CORE FORM FIELDS

=over

=item L<HTML::FormFu::Element::Button>

=item L<HTML::FormFu::Element::Checkbox>

=item L<HTML::FormFu::Element::ContentButton>

=item L<HTML::FormFu::Element::Date>

=item L<HTML::FormFu::Element::File>

=item L<HTML::FormFu::Element::Hidden>

=item L<HTML::FormFu::Element::Image>

=item L<HTML::FormFu::Element::Password>

=item L<HTML::FormFu::Element::Radiogroup>

=item L<HTML::FormFu::Element::Radio>

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

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
