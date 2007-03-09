package HTML::FormFu::QueryType::Catalyst;

use strict;
use warnings;
use base 'Class::Accessor::Chained::Fast';

use Carp qw( croak );

__PACKAGE__->mk_accessors(qw/ query name /);

sub headers {
    my ($self) = @_;

    my @uploads = $self->query->upload( $self->name );
    my @headers;

    if (@uploads) {
        for my $upload (@uploads) {
            my $http = $upload->headers;
            my %header;
            for my $key ( $http->header_field_names ) {
                $header{$key} = $http->header($key);
            }
            push @headers, \%header;
        }
        return \@headers;
    }

    return;
}

1;
