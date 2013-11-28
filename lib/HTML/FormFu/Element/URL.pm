package HTML::FormFu::Element::URL;
use Moose;

extends 'HTML::FormFu::Element';

with 'HTML::FormFu::Role::Element::Input';

has http_only  => ( is => 'rw', traits => ['Chained'] );
has https_only => ( is => 'rw', traits => ['Chained'] );

has _has_constraint => (
    is       => 'rw',
    init_arg => undef,
);

after BUILD => sub {
    my $self = shift;

    $self->field_type('url');

    return;
};

sub pre_process {
    my ( $self ) = @_;

    return if $self->_has_constraint;

    $self->_has_constraint(1);
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

    $self->constraint({
        type => 'Regex',
        common => [
            'URI',
            'HTTP',
            { -scheme => $scheme },
        ],
    });

    # 'pattern' attribute
    $self->pattern( "$scheme://.*" );

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
