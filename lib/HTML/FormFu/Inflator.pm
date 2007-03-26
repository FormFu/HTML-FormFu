package HTML::FormFu::Inflator;

use strict;
use warnings;
use base 'Class::Accessor::Chained::Fast';

use HTML::FormFu::Exception::Inflator;
use HTML::FormFu::ObjectUtil qw( populate form name );
use Carp qw( croak );
use Scalar::Util qw/ blessed /;

__PACKAGE__->mk_accessors(qw/ parent inflator_type localize_args /);

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

    my $return;
    my @errors;

    if ( ref $values eq 'ARRAY' ) {
        my @return;
        for my $value ( @$values ) {
            my ( $return ) = eval {
                $self->inflator($value);
                };
            if ($@) {
                push @errors, $self->return_error($@);
                push @return, undef;
            }
            else {
                push @return, $value;
            }
        }
        $return = \@return;
    }
    else {
        ( $return ) = eval {
            $self->inflator($values);
            };
        if ($@) {
            push @errors, $self->return_error($@);
        }
    }

    return ( $return, @errors );
}

sub return_error {
    my ( $self, $err ) = @_;
    
    if ( !blessed $err || !$err->isa('HTML::FormFu::Exception::Inflator') ) {
        $err = HTML::FormFu::Exception::Inflator->new;
    }
    
    return $err;
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
