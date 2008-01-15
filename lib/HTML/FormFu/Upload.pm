package HTML::FormFu::Upload;

use strict;
use Carp qw( croak );

use HTML::FormFu::ObjectUtil qw( form parent populate );
use Scalar::Util qw/ weaken /;

sub new {
    my $class = shift;

    my %attrs;
    eval { %attrs = %{ $_[0] } if @_ };
    croak "attributes argument must be a hashref" if $@;

    my $self = bless \%attrs, $class;

    $self->populate( \%attrs );

    return $self;
}

sub _param {
    my $self = shift;

    if (@_) {
        $self->{_param} = shift;

        weaken( $self->{_param} );
    }

    return $self->{_param};
}

1;

__END__

=head1 NAME

HTML::FormFu::Upload

=head1 DESCRIPTION

An instance is created for each uploaded file.

You will normally get an object of one of the following classes, which inherit
from L<HTML::FormFu::Upload>:

=over

=item L<HTML::FormFu::QueryType::CGI>

=item L<HTML::FormFu::QueryType::Catalyst>

=item L<HTML::FormFu::QueryType::CGI::Simple>

=back

=head1 METHODS

=head2 parent

Returns the L<field|HTML::FormFu::Element::_Field> object that the constraint 
is associated with.

=head2 form

Returns the L<HTML::FormFu> object that the constraint's field is attached 
to.

=head2 populate

See L<HTML::FormFu/populate> for details.

=head1 SEE ALSO

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
