package HTML::FormFu::Element::URL;

use Moose;
use MooseX::Attribute::FormFuChained;

extends 'HTML::FormFu::Element';

with 'HTML::FormFu::Role::Element::Input';

use HTML::FormFu::Attribute qw( mk_output_accessors );

has http_only  => ( is => 'rw', traits => ['FormFuChained'] );
has https_only => ( is => 'rw', traits => ['FormFuChained'] );

has error_message => (
    is        => 'rw',
    predicate => 'has_message',
    traits    => ['FormFuChained'],
);

has _has_auto_regex_constraint => (
    is       => 'rw',
    init_arg => undef,
);

__PACKAGE__->mk_output_accessors(qw( message ));

after BUILD => sub {
    my $self = shift;

    $self->field_type('url');

    return;
};

sub pre_process {
    my ( $self ) = @_;

    my $constraint;

    if ( $self->_has_auto_regex_constraint ) {
        $constraint = $self->_has_auto_regex_constraint;
    }
    else {
        my $scheme;

        if ( $self->http_only ) {
            $scheme = 'http';
        }
        elsif ( $self->https_only ) {
            $scheme = 'https';
        }
        else {
            $scheme = 'https?';
        }

        $constraint = $self->constraint({
            type => 'Regex',
            common => [
                'URI',
                'HTTP',
                { -scheme => $scheme },
            ],
        });

        $self->_has_auto_regex_constraint( $constraint );

        # 'pattern' attribute
        $self->pattern( "$scheme://.*" );

    }

    my $message = $self->error_message;
    if ( defined $message && length $message ) {
        $constraint->message( $message );
    }

    return;
};

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::Element::URL - HTML5 URL form field

=head1 SYNOPSIS

    my $element = $form->element( URL => 'foo' );
    
    # no need to add a separate constraint

=head1 DESCRIPTION

HTML5 URL form field which provides native client-side validation in modern browsers.

Creates an input field with C<<type="url">>.

Also sets the C<pattern> attribute to restrict the client-side validation to only
our desired schemes (http and/or https).

This element automatically adds a L<Regex constraint|HTML::FormFu::Constraint::Regex>,
so you don't have to.

If neither L</http_only> or L</https_only> are set, the constraint allows any HTTP or HTTPS url.

=head1 METHODS

=head2 http_only

=head2 https_only

=head2 message

Arguments: $string

Set the error message on the L<Regex constraint|HTML::FormFu::Constraint::Regex> which is
automatically added.

=head2 message_xml

Arguments: $string

If you don't want your error message to be XML-escaped, use the L</message_xml> method 
instead of L</message>.

=head2 message_loc

Arguments: $localization_key

Set the error message using a L10N key.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from 
L<HTML::FormFu::Role::Element::Input>, 
L<HTML::FormFu::Role::Element::Field>, 
L<HTML::FormFu::Element>.

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
