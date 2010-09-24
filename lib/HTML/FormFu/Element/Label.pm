package HTML::FormFu::Element::Label;
use Moose;

extends "HTML::FormFu::Element";

with 'HTML::FormFu::Role::Element::Field',
     'HTML::FormFu::Role::Element::SingleValueField' => { -excludes => 'nested_name' },
     'HTML::FormFu::Role::Element::Coercible';

use HTML::FormFu::Util qw( process_attrs );

has field_type     => ( is => 'rw', traits => ['Chained'] );
has label_filename => ( is => 'rw', traits => ['Chained'] );

has tag => (
    is      => 'rw',
    default => 'span',
    lazy    => 1,
    traits  => ['Chained'],
);

after BUILD => sub {
    my $self = shift;

    $self->filename('label_tag');
    $self->non_param(1);

    #$self->field_type('label');
    #$self->retain_default(1);

    $self->model_config->{read_only} = 1;
    
    return;
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

    my $html .= "<" . $self->tag;

    $html .= sprintf "%s", process_attrs( $render->{attributes} || {} );

    if ( defined $render->{nested_name} ) {
        $html .= sprintf qq{ name="%s"}, $render->{nested_name};
    }
    $html .= ">";
    if ( defined $render->{value} ) {
        $html .= sprintf qq{%s}, $render->{value};
    }
    $html .= "</" . $self->tag . ">";

    return $html;
}

sub process_input {
    my ( $self, $input ) = @_;

    my $form = $self->form;
    my $name = $self->nested_name;

    if ( $form->submitted && $form->nested_hash_key_exists( $input, $name ) ) {
        $form->delete_nested_hash_value( $input, $name );
    }

    return;
}

sub render_data_non_recursive {
    my ( $self, $args ) = @_;

    my $render = $self->SUPER::render_data_non_recursive( {
            tag => $self->tag,
            $args ? %$args : (),
        } );

    return $render;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::Element::Label - field for displaying only

=head1 DESCRIPTION

This element displays a value. This is useful if you use a model like
L<HTML::FormFu::Model::DBIC> and want to display a value from the database.
The value of this field cannot be set by the client.

See L<HTML::FormFu::Model::DBIC/"Set a field read only"> for more information
on read only fields.

=head1 METHODS

=head2 tag

Set the tag for this element.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::_Field>, L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Moritz Onken, C<< onken at houseofdesign.de >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
