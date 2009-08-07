package HTML::FormFu::Element::reCAPTCHA;

use strict;
use base 'HTML::FormFu::Element::Multi';
use Class::C3;

use HTML::FormFu::Util qw( process_attrs _merge_hashes );
use Captcha::reCAPTCHA;
use Scalar::Util qw( blessed );

__PACKAGE__->mk_item_accessors( qw(
        public_key
        private_key
        ssl
        recaptcha_options
) );

sub new {
    my $self = shift->next::method(@_);

    $self->ssl('auto');
    $self->recaptcha_options( {} );
    $self->filename('recaptcha');
    $self->constraint_args( { type => 'reCAPTCHA' } );

    $self->constraint( $self->constraint_args );

    return $self;
}

sub constraint_args {
    my ( $self, $args ) = @_;
    
    $self->{constraint_args} ||= {};
    
    if ( @_ > 1 ) {
        $self->{constraint_args} = _merge_hashes(
            $self->{constraint_args},
            $args,
        );
        
        my $constraint = $self->get_constraint( { type => 'reCAPTCHA' } );
        
        if ( defined $constraint ) {
            $constraint->populate( $self->{constraint_args} );
        }
    }
    
    return $self->{constraint_args};
}

sub render_data_non_recursive {
    my $self = shift;

    my $pubkey = $self->public_key || $ENV{RECAPTCHA_PUBLIC_KEY};
    my $error = undef;

    # prefer catalyst methods to %ENV vars
    my $query = $self->form->query;

    my $catalyst_compatible 
        = blessed($query)
        && $query->can('secure')
        && $query->can('address');

    my $use_ssl
        = $self->ssl eq 'auto' ? $catalyst_compatible
        : $query->secure ? $ENV{HTTPS}
        :                  $self->ssl;

    my $recaptcha_options = $self->recaptcha_options;

    my $recaptcha = Captcha::reCAPTCHA->new;

    my $recaptcha_html
        = $recaptcha->get_html( $pubkey, $error, $use_ssl, $recaptcha_options,
        );

    my $render = $self->next::method( {
            recaptcha_html => $recaptcha_html,
            @_ ? %{ $_[0] } : () } );

    return $render;
}

sub string {
    my ( $self, $args ) = @_;

    $args ||= {};

    my $render
        = exists $args->{render_data}
        ? $args->{render_data}
        : $self->render_data_non_recursive;

    # field wrapper template - start

    my $html = $self->_string_field_start($render);

    # reaptcha template

    $html .= sprintf "<span%s>\n", process_attrs( $render->{attributes} );

    $html .= $render->{recaptcha_html};

    $html .= "</span>";

    # field wrapper template - end

    $html .= $self->_string_field_end($render);

    return $html;
}

sub clone {
    my $self = shift;

    my $clone = $self->next::method(@_);

    $clone->recaptcha_options( dclone $self->recaptcha_options );

    return $clone;
}

1;

__END__

=head1 NAME

HTML::FormFu::Element::reCAPTCHA - "Are you human" tester!

=head1 SYNOPSIS

    ---
    elements:
      - type: reCAPTCHA
        name: recaptcha
        public_key: $recaptcha_net_public_key
        private_key: $recaptcha_net_private_key


=head1 DESCRIPTION

A wrapper around L<Captcha::reCAPTCHA>.
The reCAPTCHA fields aren't added to the form as "real" FormFu fields - so
the values are never available via L<params|HTML::FormFu/params>, etc.
You can check that the reCAPTCHA verified correctly, by the usual methods:
L<HTML::FormFu/submitted_and_valid> or L<HTML::FormFu/has_errors>

This element automatically adds L<HTML::FormFu::Constraint::reCAPTCHA> to
itself - you should never add it yourself.

Although this is a subclass of L<HTML::FormFu::Element::Multi>, you should
not call C<element()> or C<elements()> to try to add other fields - consider
the reCAPTCHA element a black box.

=head1 METHODS

=head2 name

Required. Although not visibly used for anything, you must give this field a
name for the L<reCAPTCHA constraint|HTML::FormFu::Constraint::reCAPTCHA> to
work correctly.

=head2 public_key

Arguments: $public_key

Required. Obtained from L<http://recaptcha.net>.

=head2 private_key

Arguments: $private_key

Required. Obtained from L<http://recaptcha.net>.

=head2 ssl

Default Value: 'auto'.

Valid Values: '1', '0' or 'auto'

Whether to load the recaptcha.net files via C<http> or C<https>.

If set to C<auto>, it will use C<https> urls if the current page is running
under ssl, otherwise it will use C<http> urls.

=head2 recaptcha_options

Arguments: \%options

See the recaptcha.net API for details of valid options.

    recaptcha_options:
      lang: de
      theme: white

=head2 constraint_args

Arguments: \%constraint_args

Options that will be passed to the
L<HTML::FormFu::Constraint::reCAPTCHA|reCAPTCHA constraint> that is
automatically added for you.

    ---
    elements:
      - type: reCAPTCHA
        name: recaptcha
        constraint_args:
          message: 'custom error message'

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Element::_Field>, 
L<HTML::FormFu::Element::Multi>, 
L<HTML::FormFu::Element::Block>, 
L<HTML::FormFu::Element>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
