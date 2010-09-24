package HTML::FormFu::Element::Password;
use Moose;

extends 'HTML::FormFu::Element';

with 'HTML::FormFu::Role::Element::Input';

use HTML::FormFu::Constants qw( $EMPTY_STR );

has render_value => ( is => 'rw', traits => ['Chained'] );

after BUILD => sub {
    my $self = shift;

    $self->field_type('password');

    return;
};

sub process_value {
    my ( $self, $value ) = @_;

    my $submitted = $self->form->submitted;
    my $new;

    if ( $submitted && $self->render_value ) {
        $new
            = defined $value
            ? $value
            : $EMPTY_STR;

        if ( $self->retain_default && $new eq $EMPTY_STR ) {
            $new = $self->value;
        }

        $self->value($new);
    }
    elsif ($submitted) {
        $new = $EMPTY_STR;
    }
    else {
        $new = undef;
    }

    return $new;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::Element::Password - Password form field

=head1 SYNOPSIS

    my $element = $form->element( Password => 'foo' );

=head1 DESCRIPTION

Password form field.

=head1 METHODS

=head2 render_value

Normally, when a form is redisplayed because of errors, password fields
lose their values, requiring the user to retype it.

If C<render_value> is true, password fields won't lose their value.

Default value: false

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

=cut
