use strict;
package HTML::FormFu::Element::Label;


use Moose;
use MooseX::Attribute::FormFuChained;

extends "HTML::FormFu::Element";

with 'HTML::FormFu::Role::Element::Field',
    'HTML::FormFu::Role::Element::SingleValueField',
    'HTML::FormFu::Role::Element::Coercible';

use HTML::FormFu::Util qw( process_attrs );
use List::Util 1.33 qw( none );

has field_type => ( is => 'rw', traits => ['FormFuChained'] );

has tag => (
    is      => 'rw',
    default => 'span',
    lazy    => 1,
    traits  => ['FormFuChained'],
);

after BUILD => sub {
    my $self = shift;

    $self->layout_field_filename('field_layout_label_field');
    $self->non_param(1);

    #$self->field_type('label');

    $self->model_config->{read_only} = 1;

    return;
};

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

    if (   $form->submitted
        && $form->nested_hash_key_exists( $input, $name ) )
    {
        my @fields = @{ $form->get_fields( { nested_name => $name } ) };

        if ( none { $_ == $self } @fields ) {
            $form->delete_nested_hash_key( $input, $name );
        }
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
L<HTML::FormFu::Role::Element::Field>, L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Moritz Onken, C<< onken at houseofdesign.de >>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
