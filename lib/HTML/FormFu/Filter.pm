package HTML::FormFu::Filter;

use strict;
use warnings;
use base 'Class::Accessor::Chained::Fast';

use HTML::FormFu::ObjectUtil qw( populate form name );
use Carp qw( croak );

__PACKAGE__->mk_accessors(qw/ parent filter_type /);

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
    my ( $self, $result, $params ) = @_;

    my $name = $self->name;

    # don't run filters on invalid input
    return if $result->has_errors($name);

    my $values = $params->{$name};
    if ( ref $values eq 'ARRAY' ) {
        $params->{$name} = [ map { $self->filter($_); } @$values ];
    }
    else {
        $params->{$name} = $self->filter($values);
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

HTML::Widget::Filter - Filter Base Class

=head1 SYNOPSIS

    my $filter = $form->filter( $type, @names );

=head1 DESCRIPTION

Filter Base Class.

=head1 METHODS

=head2 names

Arguments: @names

Return Value: @names

Contains names of params to filter.

=head2 process

Arguments: $form_result, \%params

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

Based on the original source code of L<HTML::Widget::Filter>, by 
Sebastian Riedel.

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
