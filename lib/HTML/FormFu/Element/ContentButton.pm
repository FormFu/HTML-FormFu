package HTML::FormFu::Element::ContentButton;

use strict;
use base 'HTML::FormFu::Element::_Field';
use Class::C3;

use HTML::FormFu::Util qw/ xml_escape /;

__PACKAGE__->mk_accessors(qw/ field_type /);
__PACKAGE__->mk_output_accessors(qw/ content /);

sub new {
    my $self = shift->next::method(@_);

    $self->filename('content_button');
    $self->multi_filename('multi_ltr');
    $self->field_type('button');

    return $self;
}

sub render {
    my $self = shift;

    my $render = $self->next::method( {
            field_type => $self->field_type,
            content    => xml_escape( $self->content ),
            @_ ? %{ $_[0] } : () } );

    return $render;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::ContentButton - Button form field containing markup

=head1 SYNOPSIS

    ---
    elements:
      type: content_button
      name: foo
      content: '<img href="/foo.png" />'
      field_type: submit

=head1 DESCRIPTION

content_button form field, rendered using provided markup.

=head1 METHODS

=head2 content

=head2 field_type

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::_Field>, 
L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
