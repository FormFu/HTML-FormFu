package HTML::FormFu::Element::Checkbox;

use strict;
use base 'HTML::FormFu::Element::_Input';
use Class::C3;

use HTML::FormFu::Constants qw( $EMPTY_STR );

__PACKAGE__->mk_output_accessors( qw( default ) );

sub new {
    my $self = shift->next::method(@_);

    $self->field_type   ( 'checkbox' );
    $self->reverse_multi( 1 );
    $self->value(1);

    return $self;
}

sub process_value {
    my ( $self, $input ) = @_;

    # ignore submitted input

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

    if (   $submitted
        && defined $value
        && defined $original
        && $value eq $original )
    {
        $render->{attributes}{checked} = 'checked';
    }
    elsif ($submitted
        && $self->retain_default
        && ( !defined $value || $value eq $EMPTY_STR ) )
    {
        $render->{attributes}{checked} = 'checked';
    }
    elsif ($submitted) {
        delete $render->{attributes}{checked};
    }
    elsif ( defined $default && defined $original && $default eq $original ) {
        $render->{attributes}{checked} = 'checked';
    }

    $self->next::method($render);

    return;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::Checkbox - Checkbox form field

=head1 SYNOPSIS

    my $e = $form->element( Checkbox => 'foo' );

=head1 DESCRIPTION

Checkbox form field.

=head1 METHODS

=head2 value

Default Value: 1

=head2 default_empty_value

Inherited. See L<HTML::FormFu::Element::_Field/default_empty_value> for details.

=head2 reverse_multi

Overrides the default value, so it's C<true>.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::_Input>, 
L<HTML::FormFu::Element::_Field>, 
L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
