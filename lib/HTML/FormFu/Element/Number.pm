package HTML::FormFu::Element::Number;

use strict;
use base 'HTML::FormFu::Element::Text';
use Class::C3;

sub new {
    my $self = shift->next::method(@_);
    
    $self->field_type('number');
    
    $self->deflator( 'FormatNumber' );
    $self->filter(   'FormatNumber' );
    
    return $self;
}

sub precision {
    my $self = shift;
    
    return $self->get_deflator({ type => 'FormatNumber' })->precision(@_);
}

sub trailing_zeroes {
    my $self = shift;
    
    return $self->get_deflator({ type => 'FormatNumber' })->trailing_zeroes(@_);
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::Number - Number element with formatting

=head1 SYNOPSIS

  ---
  elements:
    - type: Number
      locale: de_DE
      precision: 2
      trailing_zeroes: 1


=head1 DESCRIPTION

This element formats numbers according to the current locale. You can set this
locale either by setting C<< $form->locale >> or by setting the element's
locale. If none of them is set the element uses the system's locale.

=head1 METHODS

=head2 locale

Set the locale for this element. The format of the number is chosen according
to this locale.

=head2 precision

Set the precision for the number. Defaults to C<2>.

=head2 trailing_zeroes

If this is set to C<1> the number has trailing zeroes. Defaults to C<0>. 

=head1 SEE ALSO

L<HTML::FormFu::Deflator::FormatNumber>

L<HTML::FormFu::Filter::FormatNumber>

L<HTML::FormFu/locale>

=head1 AUTHOR

Moritz Onken C< onken at houseofdesign.de >
