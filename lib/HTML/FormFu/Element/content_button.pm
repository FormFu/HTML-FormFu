package HTML::FormFu::Element::content_button;

use strict;
use warnings;
use base 'HTML::FormFu::Element::field';

__PACKAGE__->mk_accessors(qw/ field_type content /);

sub new {
    my $self = shift->SUPER::new(@_);

    $self->filename('content_button');
    $self->multi_filename('multi_ltr');
    $self->field_type('button');

    return $self;
}

sub render {
    my $self = shift;

    my $render = $self->SUPER::render({
        field_type => $self->field_type,
        content    => $self->content,
        @_ ? %{$_[0]} : ()
        });

    return $render;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::content_button - Button form field containing markup

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

Is a sub-class of, and inherits methods from L<HTML::FormFu::Element::field>, 
L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
