package HTML::FormFu::Element::ContentButton;

use Moose;
use MooseX::Attribute::Chained;
extends "HTML::FormFu::Element";
with 'HTML::FormFu::Role::Element::Field';
with "HTML::FormFu::Role::Element::SingleValueField";

use HTML::FormFu::Util qw( xml_escape process_attrs );

__PACKAGE__->mk_output_accessors(qw( content ));

has field_type => (
    is      => 'rw',
    default => 'button',
    lazy    => 1,
    traits  => ['Chained'],
);

after BUILD => sub {
    my ( $self, $args ) = @_;

    $self->filename( 'content_button' );
    
    return;
};

sub render_data_non_recursive {
    my ( $self, $args ) = @_;

    my $render = $self->SUPER::render_data_non_recursive( {
            field_type => $self->field_type,
            content    => xml_escape( $self->content ),
            $args ? %$args : (),
        } );

    return $render;
}

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

    # content_button template

    my $html .= sprintf qq{<button name="%s" type="%s"},
        $render->{nested_name},
        $render->{field_type},
        ;

    if ( defined $render->{value} ) {
        $html .= sprintf qq{ value="%s"}, $render->{value};
    }

    $html .= sprintf "%s>%s</button>",
        process_attrs( $render->{attributes} ),
        ( defined $render->{content} ? $render->{content} : '' ),
        ;

    return $html;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::Element::ContentButton - Button form field containing markup

=head1 SYNOPSIS

    ---
    elements:
      type: ContentButton
      name: foo
      content: '<img href="/foo.png" />'
      field_type: Submit

=head1 DESCRIPTION

content_button form field, rendered using provided markup.

=head1 METHODS

=head2 content

=head2 field_type

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::_Field>, 
L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
