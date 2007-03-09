package HTML::FormFu::QueryType::CGI;

use strict;
use warnings;
use base 'Class::Accessor::Chained::Fast';

use Carp qw( croak );

__PACKAGE__->mk_accessors(qw/ query name /);

sub headers {
    my ($self) = @_;

    my @filenames = $self->query->param( $self->name );
    my @headers;

    if (@filenames) {
        for my $file (@filenames) {
            push @headers, $self->query->uploadInfo($file);
        }
        return \@headers;
    }

    return;
}

1;
