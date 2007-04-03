package HTML::FormFu::Element::password;

use strict;
use warnings;
use base 'HTML::FormFu::Element::input';

__PACKAGE__->mk_accessors(qw/ render_value /);

sub new {
    my $self = shift->SUPER::new(@_);

    $self->field_type('password');

    return $self;
}

sub process_value {
    my ( $self, $value ) = @_;
    
    my $submitted = $self->form->submitted;
    my $new;

    if ( $submitted && $self->render_value ) {
        $new = defined $value ? $value : "";

        $new = $self->value if $self->retain_default && $new eq "";

        $self->value($new);
    }
    elsif ($submitted) {
        $new = "";
    }
    else {
        $new = undef;
    }

    return $new;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::Password - Password form field

=head1 SYNOPSIS

    my $element = $form->element( Password => 'foo' );

=head1 DESCRIPTION

Password form field.

=head1 METHODS

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Element::input>, 
L<HTML::FormFu::Element::field>, L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
