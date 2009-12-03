package HTML::FormFu::Model;

use strict;
use Class::C3;

use HTML::FormFu::Attribute qw( mk_accessors mk_item_accessors );
use HTML::FormFu::ObjectUtil qw( form parent );
use Scalar::Util qw( refaddr reftype );
use Carp qw( croak );

__PACKAGE__->mk_item_accessors(qw( type ));

sub new {
    my $class = shift;
    my %attrs;
    
    if (@_) {
        croak "attributes argument must be a hashref"
            if reftype( $_[0] ) ne 'HASH';
        
        %attrs = %{ $_[0] };
    }
    
    my $self = bless {}, $class;

    for my $arg (qw( parent type )) {
        croak "$arg attribute required" if !exists $attrs{$arg};

        $self->$arg( $attrs{$arg} );
    }

    return $self;
}

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
