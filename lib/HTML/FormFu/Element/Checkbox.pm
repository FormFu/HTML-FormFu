package HTML::FormFu::Element::Checkbox;

use Moose;

extends 'HTML::FormFu::Element';

with 'HTML::FormFu::Role::Element::Input';

use HTML::FormFu::Constants qw( $EMPTY_STR );

__PACKAGE__->mk_output_accessors(qw( default ));

after BUILD => sub {
    my ( $self, $args ) = @_;

    $self->field_type('checkbox');
    $self->value(1);

    $self->multi_layout( [
        'field',
        'label',
    ] );

    return;
};

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

    if (defined $value and ref $value eq 'ARRAY') {
        $value = $original if grep { $_ eq $original } @$value;
    }

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

    $self->SUPER::prepare_attrs($render);

    return;
}

__PACKAGE__->meta->make_immutable;

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

Inherited. See L<HTML::FormFu::Role::Element::Field/default_empty_value> for details.

=head2 multi_layout

Overrides the default value of 
L<multi_layout|HTML::FormFu::Role::Element::Field/multi_layout>
to swap the C<field> and C<label> around.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Role::Element::Input>, 
L<HTML::FormFu::Role::Element::Field>, 
L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
