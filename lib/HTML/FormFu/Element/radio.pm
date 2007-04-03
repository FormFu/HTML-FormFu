package HTML::FormFu::Element::radio;

use strict;
use warnings;
use base 'HTML::FormFu::Element::input';

__PACKAGE__->mk_output_accessors(qw/ default /);

sub new {
    my $self = shift->SUPER::new(@_);

    $self->field_type('radio');
    $self->multi_filename('multi_rtl');

    return $self;
}

sub process_value {
    my ( $self, $value ) = @_;

    return $self->value;
}

sub prepare_attrs {
    my ( $self, $render ) = @_;

    my $submitted = $self->form->submitted;
    my $default   = $self->default;
    my $original  = $self->value;
    my $value     = $self->form->input->{ $self->name };

    if ( $submitted && defined $value && $value eq $original ) {
        $render->attributes( 'checked', 'checked' );
    }
    elsif ($submitted
        && $self->retain_default
        && ( !defined $value || $value eq "" ) )
    {
        $render->attributes( 'checked' => 'checked' );
    }
    elsif ($submitted) {
        delete $render->attributes->{checked};
    }
    elsif ( defined $default && $default eq $original ) {
        $render->attributes( 'checked' => 'checked' );
    }
    
    $self->SUPER::prepare_attrs($render);

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

=head1 SEE ALSO

Is a sub-class of, and inherits methods from  L<HTML::FormFu::Element::input>, 
L<HTML::FormFu::Element::field>, L<HTML::FormFu::Element>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
