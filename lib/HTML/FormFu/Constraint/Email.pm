package HTML::FormFu::Constraint::Email;

use strict;
# VERSION

use Moose;
use MooseX::Attribute::FormFuChained;

extends 'HTML::FormFu::Constraint';

use Email::Valid;

has options => ( is => 'rw', traits => ['FormFuChained'] );

sub constrain_value {
    my ( $self, $value ) = @_;

    return 1 if !defined $value || $value eq '';

    my %options = ( -address => $value );

    if (defined $self->options) {

       if (ref $self->options eq 'ARRAY') {

          for my $foo (@{ $self->options }) {
              next if $foo eq 'address';
              $options{ '-' . $foo } = 1
          }

       }
       elsif (ref $self->options eq 'HASH') {

          for my $foo (keys %{ $self->options }) {
              next if $foo eq 'address';
              $options{ '-' . $foo } = $self->options->{$foo}
          }

       }
       else {

           $options{ '-' . $self->options } = 1

       }

    }

    my $ok = Email::Valid->address( %options );

    return $ok;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::Email - Email Address Constraint

=head1 DESCRIPTION

Checks the input value is an email address according to the C<address>
method of L<Email::Valid>.

=head1 METHODS

=head2 options

Arguments: $string

Arguments: \@strings

Arguments: \%keypairs

Options are passed to L<Email::Valid>. An array or single option is
passd through with each option as 'true'. Using a hash instead, you
can pass through more specific key pair options. Remeber in both
cases to omitted the leading dash that you would otherwise need if
using L<Email::Valid> directly.

  type: Email
  options:
    - macheck
    - tldcheck
    - fudge
    - fqdn
    - allow_ip
    - local_rules

=head2 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

The available options are as per L<Email::Valid> but without the '-'

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>, Dean Hamstead C<dean@bytefoundry.com.au>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
