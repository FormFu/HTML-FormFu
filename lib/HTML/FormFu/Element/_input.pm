package HTML::FormFu::Element::_input;

use strict;
use warnings;
use base 'HTML::FormFu::Element::_field';
use Class::C3;

use HTML::FormFu::ObjectUtil qw/ _coerce /;

__PACKAGE__->mk_accessors(qw/ field_type /);

__PACKAGE__->mk_attr_accessors(qw/ checked size maxlength alt /);

sub new {
    my $self = shift->next::method(@_);

    $self->filename('input');
    $self->field_filename('input_tag');
    $self->multi_filename('multi_ltr');

    return $self;
}

sub render {
    my $self = shift;

    my $render = $self->next::method({
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

HTML::FormFu::Element::_input - input field base-class

=head1 DESCRIPTION

Base-class for L<HTML::FormFu::Element::button>, 
L<HTML::FormFu::Element::checkbox>, 
L<HTML::FormFu::Element::file>, 
L<HTML::FormFu::Element::hidden>, 
L<HTML::FormFu::Element::password>, 
L<HTML::FormFu::Element::radio>, 
L<HTML::FormFu::Element::text>.

=head1 METHODS

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::_field>, L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
