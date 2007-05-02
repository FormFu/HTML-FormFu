package HTML::FormFu::Element::input;

use strict;
use warnings;
use base 'HTML::FormFu::Element::field';

use HTML::FormFu::ObjectUtil qw/ _coerce /;

__PACKAGE__->mk_accessors(qw/ field_type /);

__PACKAGE__->mk_attr_accessors(qw/ checked size maxlength alt /);

sub new {
    my $self = shift->SUPER::new(@_);

    $self->filename('input');
    $self->field_filename('input_tag');
    $self->multi_filename('multi_ltr');

    return $self;
}

sub render {
    my $self = shift;

    my $render = $self->SUPER::render({
        field_type => $self->field_type,
        @_ ? %{$_[0]} : ()
        });

    return $render;
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

HTML::FormFu::Element::input - input field base-class

=head1 DESCRIPTION

Base-class for L<HTML::FormFu::Element::Button>, 
L<HTML::FormFu::Element::Checkbox>, L<HTML::FormFu::Element::File>, 
L<HTML::FormFu::Element::Hidden>, L<HTML::FormFu::Element::Password>, 
L<HTML::FormFu::Element::Radio>, L<HTML::FormFu::Element::Text>.

=head1 METHODS

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Element::field>, 
L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
