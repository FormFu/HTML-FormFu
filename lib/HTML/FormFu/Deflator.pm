package HTML::FormFu::Deflator;

use strict;
use warnings;
use base 'Class::Accessor::Chained::Fast';

use HTML::FormFu::ObjectUtil qw( populate form name );
use Carp qw( croak );

__PACKAGE__->mk_accessors(qw/ parent type /);

sub new {
    my $class = shift;

    my %attrs;
    eval { %attrs = %{ $_[0] } if @_ };
    croak "attributes argument must be a hashref" if $@;

    my $self = bless {}, $class;

    $self->populate( \%attrs );

    return $self;
}

sub process {
    my ( $self, $values ) = @_;

    if ( ref $values eq 'ARRAY' ) {
        return [ map { $self->deflator($_); } @$values ];
    }
    else {
        return $self->deflator($values);
    }
}

sub clone {
    my ( $self ) = @_;
    
    my %new = %$self;
    
    return bless \%new, ref $self;
}

1;

__END__

=head1 NAME

HTML::FormFu::Filter - Deflator Base Class

=head1 SYNOPSIS

    my $deflator = $form->deflator( $type, @names );

=head1 DESCRIPTION

Deflator Base Class.

=head1 METHODS

=head2 names

Arguments: @names

Return Value: @names

Contains names of params to deflator.

=head2 process

Arguments: $form_result, \%params

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
