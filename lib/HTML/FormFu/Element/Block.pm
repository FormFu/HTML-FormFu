package HTML::FormFu::Element::Block;

use strict;
use warnings;
use base 'HTML::FormFu::Element';
use Class::C3;

use HTML::FormFu::Accessor qw/ mk_output_accessors /;
use HTML::FormFu::Attribute qw/
    mk_add_methods mk_single_methods mk_require_methods mk_get_methods
    mk_get_one_methods /;
use HTML::FormFu::ObjectUtil qw/
    _single_element _require_constraint
    get_fields get_field get_errors get_error clear_errors
    get_elements get_element get_all_elements get_all_element insert_before
    insert_after /;
use HTML::FormFu::Util qw/ _parse_args _get_elements xml_escape /;
use Storable qw( dclone );
use Carp qw/croak/;

__PACKAGE__->mk_accessors(qw/ tag _elements element_defaults /);

__PACKAGE__->mk_output_accessors(qw/ content /);

__PACKAGE__->mk_inherited_accessors(
    qw/ auto_id auto_label auto_error_class auto_error_message
        auto_constraint_class auto_inflator_class auto_validator_class
        auto_transformer_class render_processed_value force_errors /
);

__PACKAGE__->mk_add_methods(
    qw/
        element deflator filter constraint inflator valiBdator transformer /
);

__PACKAGE__->mk_single_methods(
    qw/
        deflator constraint filter inflator validator transformer /
);

__PACKAGE__->mk_require_methods(
    qw/
        deflator filter inflator validator transformer /
);

__PACKAGE__->mk_get_methods(
    qw/
        deflator filter constraint inflator validator transformer /
);

__PACKAGE__->mk_get_one_methods(
    qw/
        deflator filter constraint inflator validator transformer /
);

*elements     = \&element;
*constraints  = \&constraint;
*deflators    = \&deflator;
*filters      = \&filters;
*inflators    = \&inflator;
*validators   = \&validator;
*transformers = \&transformer;

sub new {
    my $self = shift->next::method(@_);

    $self->_elements( [] );
    $self->element_defaults( {} );
    $self->render_class_suffix('block');
    $self->filename('block');
    $self->tag('div');

    return $self;
}

sub process {
    my ($self) = @_;

    map { $_->process } @{ $self->_elements };

    return;
}

sub prepare_id {
    my ( $self, $render ) = @_;

    map { $_->prepare_id(@_) } @{ $self->_elements };

    return;
}

sub render {
    my $self = shift;

    my $render = $self->next::method( {
            tag       => $self->tag,
            content   => xml_escape( $self->content ),
            _elements => [ map { $_->render } @{ $self->_elements } ],
            @_ ? %{ $_[0] } : () } );

    return $render;
}

sub start {
    return shift->render->start;
}

sub end {
    return shift->render->end;
}

sub clone {
    my $self = shift;

    my $clone = $self->next::method(@_);

    $clone->_elements( [ map { $_->clone } @{ $self->_elements } ] );

    $clone->element_defaults( dclone $self->element_defaults );

    return $clone;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::Block - Block element

=head1 SYNOPSIS

    ---
    elements: 
      - type: block
        elements: 
          - type: text
            name: foo
    
      - type: Block
        tag: span
        content: Whatever

=head1 DESCRIPTION

Block element which may contain other elements.

=head1 METHODS

=head2 tag

Specifies which tag name should be used to render the block.

Default Value: 'div'

=head2 content

If L</content> is set, it is used as the block's contents, and any attached 
elements are ignored.

=head2 content_xml

Arguments: $string

If you don't want the content to be XML-escaped, use the L</content_xml> 
method instead of </content>.

=head2 content_loc

Arguments: $localization_key

To set the content to a localized string, set L</content_loc> to a key in 
your L10N file instead of using L</content>.

=head2 elements

See L<HTML::FormFu/elements> for details.

=head2 element

See L<HTML::FormFu/element> for details.

=head2 deflators

See L<HTML::FormFu/deflators> for details.

=head2 deflator

See L<HTML::FormFu/deflator> for details.

=head2 filters

See L<HTML::FormFu/filters> for details.

=head2 filter

See L<HTML::FormFu/filter> for details.

=head2 constraints

See L<HTML::FormFu/constraints> for details.

=head2 constraint

See L<HTML::FormFu/constraint> for details.

=head2 inflators

See L<HTML::FormFu/inflators> for details.

=head2 inflator

See L<HTML::FormFu/inflator> for details.

=head2 validators

See L<HTML::FormFu/validators> for details.

=head2 validator

See L<HTML::FormFu/validator> for details.

=head2 transformers

See L<HTML::FormFu/transformers> for details.

=head2 transformer

See L<HTML::FormFu/transformer> for details.

=head1 CSS CLASSES

=head2 auto_id

See L<HTML::FormFu/auto_id> for details.

=head2 auto_label

See L<HTML::FormFu/auto_label> for details.

=head2 auto_error_class

See L<HTML::FormFu/auto_error_class> for details.

=head2 auto_error_message

See L<HTML::FormFu/auto_error_message> for details.

=head2 auto_constraint_class

See L<HTML::FormFu/auto_constraint_class> for details.

=head2 auto_inflator_class

See L<HTML::FormFu/auto_inflator_class> for details.

=head2 auto_validator_class

See L<HTML::FormFu/auto_validator_class > for details.

=head2 auto_transformer_class

See L<HTML::FormFu/auto_transformer_class> for details.

=head1 RENDERING

=head2 start

=head2 end

=head1 INTROSPECTION

=head2 get_elements

See L<HTML::FormFu/get_elements> for details.

=head2 get_element

See L<HTML::FormFu/get_element> for details.

=head2 get_all_elements

See L<HTML::FormFu/get_all_elements> for details.

=head2 get_fields

See L<HTML::FormFu/get_fields> for details.

=head2 get_field

See L<HTML::FormFu/get_field> for details.

=head2 get_deflators

See L<HTML::FormFu/get_deflators> for details.

=head2 get_deflator

See L<HTML::FormFu/get_deflator> for details.

=head2 get_filters

See L<HTML::FormFu/get_filters> for details.

=head2 get_filter

See L<HTML::FormFu/get_filter> for details.

=head2 get_constraints

See L<HTML::FormFu/get_constraints> for details.

=head2 get_constraint

See L<HTML::FormFu/get_constraint> for details.

=head2 get_inflators

See L<HTML::FormFu/get_inflators> for details.

=head2 get_inflator

See L<HTML::FormFu/get_inflator> for details.

=head2 get_validators

See L<HTML::FormFu/get_validators> for details.

=head2 get_validator

See L<HTML::FormFu/get_validator> for details.

=head2 get_transformers

See L<HTML::FormFu/get_transformers> for details.

=head2 get_transformer

See L<HTML::FormFu/get_transformer> for details.

=head2 get_errors

See L<HTML::FormFu/get_errors> for details.

=head2 clear_errors

See L<HTML::FormFu/clear_errors> for details.

=head1 SEE ALSO

Base-class for L<HTML::FormFu::Element::Fieldset>.

Is a sub-class of, and inherits methods from L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
