package HTML::FormFu::Role::Element::Input;
use Moose::Role;
use MooseX::SetOnce;

with 'HTML::FormFu::Role::Element::Field',
    'HTML::FormFu::Role::Element::FieldMethods' =>
    { -excludes => 'nested_name' },
    'HTML::FormFu::Role::Element::Coercible';

use HTML::FormFu::Attribute qw(
    mk_attr_accessors
    mk_output_accessors
    mk_inherited_accessors
    mk_inherited_merging_accessors
    mk_attr_bool_accessors
);
use HTML::FormFu::Util qw( process_attrs );

has field_type => (
    is => 'rw',

    #traits   => ['SetOnce'],
);

__PACKAGE__->mk_attr_accessors(qw(
    alt         autocomplete
    checked     maxlength
    pattern     placeholder
    size
));

__PACKAGE__->mk_attr_bool_accessors(qw(
    autofocus
    multiple
    required
));

after BUILD => sub {
    my $self = shift;

    $self->filename('input');
    $self->field_filename('input_tag');

    return;
};

around render_data_non_recursive => sub {
    my ( $orig, $self, $args ) = @_;

    my $render = $self->$orig($args);

    $render->{field_type} = $self->field_type;

    $render->{placeholder} = $self->placeholder;

    #$self->_field_render_data_non_recursive;

    return $render;
};

sub string {
    my ( $self, $args ) = @_;

    $args ||= {};

    my $render
        = exists $args->{render_data}
        ? $args->{render_data}
        : $self->render_data;

    # field wrapper template - start

    my $html = $self->_string_field_start($render);

    # input_tag template

    $html .= $self->_string_field($render);

    # field wrapper template - end

    $html .= $self->_string_field_end($render);

    return $html;
}

sub _string_field {
    my ( $self, $render ) = @_;

    my $html .= "<input";

    if ( defined $render->{nested_name} ) {
        $html .= sprintf qq{ name="%s"}, $render->{nested_name};
    }

    $html .= sprintf qq{ type="%s"}, $render->{field_type};

    if ( defined $render->{value} ) {
        $html .= sprintf qq{ value="%s"}, $render->{value};
    }

    if ( defined $render->{placeholder} ) {
        $html .= sprintf qq{ placeholder="%s"}, $render->{placeholder};
    }

    $html .= sprintf "%s />", process_attrs( $render->{attributes} );

    return $html;
}

sub as {
    my ( $self, $type, %attrs ) = @_;

    return $self->_coerce(
        type       => $type,
        attributes => \%attrs,
        errors     => $self->_errors,
        package    => __PACKAGE__,
    );
}

1;

__END__

=head1 NAME

HTML::FormFu::Role::Element::Input - Role for input fields

=head1 DESCRIPTION

Base-class for L<HTML::FormFu::Element::Button>, 
L<HTML::FormFu::Element::Checkbox>, 
L<HTML::FormFu::Element::File>, 
L<HTML::FormFu::Element::Hidden>, 
L<HTML::FormFu::Element::Password>, 
L<HTML::FormFu::Element::Radio>, 
L<HTML::FormFu::Element::Text>.

=head1 ATTRIBUTE ACCESSORS

Get / set input attributes directly with these methods.

Arguments: [$string]

Return Value: $string

=head2 alt

=head2 autocomplete

=head2 checked

=head2 maxlength

=head2 pattern

=head2 placeholder

=head2 size

=head1 BOOLEAN ATTRIBUTE ACCESSORS

Arguments: [$bool]

Return Value: $self
Return Value: $string
Return Value: undef

Get / set boolean XHTML attributes such as C<required="required">.

If given any true argument, the attribute value will be set equal to the attribute
key name. E.g. C<< $element->required(1) >> will set the attribute C<< required="required" >>.

If given a false argument, the attribute key will be deleted.

When used as a setter, the return value is C<< $self >> to allow chaining.

=head2 autofocus

=head2 multiple

=head2 required

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Role::Element::Field>, L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
