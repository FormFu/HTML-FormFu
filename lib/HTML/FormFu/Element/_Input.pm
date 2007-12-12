package HTML::FormFu::Element::_Input;

use strict;
use base 'HTML::FormFu::Element::_Field';
use Class::C3;

use HTML::FormFu::ObjectUtil qw/ _coerce /;
use HTML::FormFu::Util qw/ process_attrs /;

__PACKAGE__->mk_accessors(qw/ field_type /);

__PACKAGE__->mk_attr_accessors(qw/ checked size maxlength alt /);

sub new {
    my $self = shift->next::method(@_);

    $self->filename('input');
    $self->field_filename('input_tag');

    return $self;
}

sub render_data_non_recursive {
    my $self = shift;

    my $render = $self->next::method( {
            field_type => $self->field_type,
            @_ ? %{ $_[0] } : () } );

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

    my $html .= "<input";

    if ( defined $render->{nested_name} ) {
        $html .= sprintf qq{ name="%s"}, $render->{nested_name};
    }

    $html .= sprintf qq{ type="%s"}, $render->{field_type};

    if ( defined $render->{value} ) {
        $html .= sprintf qq{ value="%s"}, $render->{value};
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

HTML::FormFu::Element::_Input - input field base-class

=head1 DESCRIPTION

Base-class for L<HTML::FormFu::Element::Button>, 
L<HTML::FormFu::Element::Checkbox>, 
L<HTML::FormFu::Element::File>, 
L<HTML::FormFu::Element::Hidden>, 
L<HTML::FormFu::Element::Password>, 
L<HTML::FormFu::Element::Radio>, 
L<HTML::FormFu::Element::Text>.

=head1 METHODS

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::_Field>, L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
