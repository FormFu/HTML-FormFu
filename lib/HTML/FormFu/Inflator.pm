package HTML::FormFu::Inflator;

use strict;
use warnings;
use base 'Class::Accessor::Chained::Fast';

use HTML::FormFu::ObjectUtil qw( populate form name );
use Carp qw( croak );

__PACKAGE__->mk_accessors(qw/ parent inflator_type /);

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
        return [ map { $self->inflator($_); } @$values ];
    }
    else {
        return $self->inflator($values);
    }

    return;
}

sub clone {
    my ( $self ) = @_;
    
    my %new = %$self;
    
    return bless \%new, ref $self;
}

1;

__END__

=head1 NAME

HTML::Widget::Filter - Inflator Base Class

=head1 SYNOPSIS

    my $inflator = $form->inflator( $type, @names );

=head1 DESCRIPTION

Inflator Base Class.

=head1 METHODS

=head2 names

Arguments: @names

Return Value: @names

Contains names of params to inflator.

=head2 process

Arguments: $form_result, \%params

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
