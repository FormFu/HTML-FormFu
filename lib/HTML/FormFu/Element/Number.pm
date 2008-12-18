package HTML::FormFu::Element::Number;

use strict;
use base 'HTML::FormFu::Element::Text';
use Class::C3;

__PACKAGE__->mk_item_accessors(qw(locale));

sub new {
  my $self = shift->next::method(@_);
  $self->deflator( { type => "FormatNumber", locale => $self->locale } );
  $self->filter( { type => "FormatNumber", locale => $self->locale } );
  return $self;
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


=head1 DESCRIPTION

This element formats numbers according to the current locale. You can set this locale either by setting C<< $form->locale >> or by setting the element's locale. If none of them is set the element uses the system's locale.

=head1 METHODS

=head2 locale

Set the locale for this element. The format of the number is chosen according to this locale.

=head1 SEE ALSO

L<HTML::FormFu::Deflator::FormatNumber>

L<HTML::FormFu::Filter::FormatNumber>

L<HTML::FormFu/locale>

=head1 AUTHOR

Moritz Onken C< onken at houseofdesign.de >

