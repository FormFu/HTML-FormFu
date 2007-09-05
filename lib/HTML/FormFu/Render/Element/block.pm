package HTML::FormFu::Render::Element::block;

use strict;
use base 'HTML::FormFu::Render::Element';

use HTML::FormFu::Util qw/ _parse_args _get_elements /;

__PACKAGE__->mk_accessors(qw/ content /);

sub elements {
    my $self = shift;
    my %args = _parse_args(@_);

    my @elements = @{ $self->{_elements} };

    return _get_elements( \%args, \@elements );
}

sub element {
    my $self = shift;

    my $e = $self->elements(@_);

    return @$e ? $e->[0] : ();
}

sub fields {
    my $self = shift;
    my %args = _parse_args(@_);

    my @e = map { $_->is_field ? $_ : @{ $_->fields } } @{ $self->{_elements} };

    return _get_elements( \%args, \@e );
}

sub field {
    my $self = shift;

    my $f = $self->fields(@_);

    return @$f ? $f->[0] : ();
}

sub start {
    my ($self) = @_;

    return $self->output('start_block');
}

sub end {
    my ($self) = @_;

    return $self->output('end_block');
}

1;
