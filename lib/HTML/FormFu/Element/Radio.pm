package HTML::FormFu::Element::Radio;

use strict;
use base 'HTML::FormFu::Element::_Input';
use Class::C3;

__PACKAGE__->mk_output_accessors(qw/ default /);

sub new {
    my $self = shift->next::method(@_);

    $self->field_type('radio');
    $self->reverse_multi(1);

    return $self;
}

sub process_value {
    my ( $self, $value ) = @_;

    return $self->value;
}

sub prepare_attrs {
    my ( $self, $render ) = @_;

    my $form      = $self->form;
    my $submitted = $form->submitted;
    my $default   = $self->default;
    my $original  = $self->value;
    my $value
        = defined $self->name
        ? $self->get_nested_hash_value( $form->input, $self->nested_name )
        : undef;

    if ( $submitted && defined $value && $value eq $original ) {
        $render->{attributes}{checked} = 'checked';
    }
    elsif ($submitted
        && $self->retain_default
        && ( !defined $value || $value eq "" ) )
    {
        $render->{attributes}{checked} = 'checked';
    }
    elsif ($submitted) {
        delete $render->{attributes}{checked};
    }
    elsif ( defined $default && $default eq $original ) {
        $render->{attributes}{checked} = 'checked';
    }

    $self->next::method($render);

    return;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::Radio - Radio form field

=head1 SYNOPSIS

    my $element = $form->element( Radio => 'foo' );

=head1 DESCRIPTION

Radio form field.

=head1 METHODS

=head2 reverse_multi

Overrides the default value, so it's C<true>.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::_Input>, 
L<HTML::FormFu::Element::_Field>, 
L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
