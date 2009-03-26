package HTML::FormFu::Element::Textarea;

use strict;
use base 'HTML::FormFu::Element::_Field';
use Class::C3;

use HTML::FormFu::Util qw( process_attrs );

__PACKAGE__->mk_attr_accessors(qw( cols rows ));

sub new {
    my $self = shift->next::method(@_);

    $self->filename('input');
    $self->field_filename('textarea_tag');
    $self->cols(40);
    $self->rows(20);

    return $self;
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

    # textarea_tag template

    my $html = sprintf qq{<textarea name="%s"%s>},
        $render->{nested_name},
        process_attrs( $render->{attributes} ),
        ;

    if ( defined $render->{value} ) {
        $html .= $render->{value};
    }

    $html .= "</textarea>";

    return $html;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::Textarea - Textarea form field

=head1 SYNOPSIS

    my $element = $form->element( Text => 'foo' );

=head1 DESCRIPTION

Text form field.

=head1 METHODS

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
