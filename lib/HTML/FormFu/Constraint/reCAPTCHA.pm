package HTML::FormFu::Constraint::reCAPTCHA;

use strict;
use base 'HTML::FormFu::Constraint';

use Captcha::reCAPTCHA;
use Scalar::Util qw( blessed );

__PACKAGE__->mk_item_accessors( qw( _recaptcha_response ) );

sub process {
    my ( $self, $params ) = @_;

    # check when condition
    return unless $self->_process_when($params);

    # we need the original query object, as the recaptcha fields aren't
    # real formfu fields, so they won't be in $params
    my $query = $self->form->query;

    my $challenge = $query->param('recaptcha_challenge_field');
    my $response  = $query->param('recaptcha_response_field');

    # constraints are only run if submitted() is true.
    # the recaptcha fields have an implicit Required constraint
    # so throw an error if either field is missing
    if ( !$challenge || !$response ) {
        return $self->mk_errors({})
    }

    # check if it's already been run - as a 2nd check to recaptcha.net
    # will otherwise always fail
    my $previous_response = $self->_recaptcha_response;

    if ( $previous_response ) {
        if ( $previous_response ne 'true' ) {
            return $self->mk_errors({
                message => $previous_response,
            });
        }
        else {
            # the previous response was OK, so return with no errors
            return;
        }
    }
   
    my $catalyst_compatible
        =  blessed( $query )
        && $query->can('secure')
        && $query->can('address');

    my $captcha = Captcha::reCAPTCHA->new;
    my $privkey = $self->parent->private_key || $ENV{RECAPTCHA_PRIVATE_KEY};

    my $remoteip = $catalyst_compatible ? $query->address
                 :                        $ENV{REMOTE_ADDR}
                 ;
    
    my $result = $captcha->check_answer(
        $privkey,
        $remoteip,
        $challenge,
        $response,
    );

    # they're human!
    if ( $result->{is_valid} ) {
        $self->_recaptcha_response( 'true' );
        return;
    }
    
    # response failed
    $self->_recaptcha_resonse( $result->{error} );
    
    return $self->mk_errors({
        message => $result->{error},
    });
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::reCAPTCHA - not for direct use

=head1 DESCRIPTION

This constraint is automatically added by the
L<reCAPTCHA element|HTML::FormFu::Element::reCAPTCHA>, and should not be used
directly.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from  
L<HTML::FormFu::Constraint::_others>, L<HTML::FormFu::Constraint>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
