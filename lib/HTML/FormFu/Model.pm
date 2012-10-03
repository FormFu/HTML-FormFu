package HTML::FormFu::Model;
use Moose;
use MooseX::Attribute::Chained;

with 'HTML::FormFu::Role::HasParent';

use HTML::FormFu::ObjectUtil qw( form parent );
use Scalar::Util qw( refaddr reftype );
use Carp qw( croak );

has type => ( is => 'rw', traits => ['Chained'] );

sub default_values {
    croak "'default_values' method not implemented by Model class";
}

sub update {
    croak "'update' method not implemented by Model class";
}

sub create {
    croak "'create' method not implemented by Model class";
}

sub options_from_model {
    croak "'options_from_model' method not implemented by Model class";
}

sub clone {
    my ($self) = @_;

    my %new = %$self;

    return bless \%new, ref $self;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::Model - base class for models

=head1 SEE ALSO

L<HTML::FormFu::Model::DBIC>

L<HTML::FormFu::Model::LDAP>

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
