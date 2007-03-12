package HTML::FormFu::Element::fieldset;

use strict;
use warnings;
use base 'HTML::FormFu::Element::block';

__PACKAGE__->mk_accessors(qw/ legend /);

sub new {
    my $self = shift->SUPER::new(@_);

    $self->tag('fieldset');

    return $self;
}

sub render {
    my $self = shift;

    my $render = $self->SUPER::render({
        legend => $self->legend,
        @_ ? %{$_[0]} : ()
        });

    return $render;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::Fieldset - Fieldset element

=head1 SYNOPSIS

    my $fs = $form->element( Fieldset => 'address' );

=head1 DESCRIPTION

Fieldset element.

=head1 METHODS

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Element::Block>, 
L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
