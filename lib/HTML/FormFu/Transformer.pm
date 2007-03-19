package HTML::FormFu::Transformer;

use strict;
use warnings;
use base 'Class::Accessor::Chained::Fast';

use HTML::FormFu::Accessor qw( mk_output_accessors );
use HTML::FormFu::Exception::Validator;
use HTML::FormFu::ObjectUtil qw( populate form name );
use Scalar::Util qw/ blessed /;
use Carp qw/ croak /;

__PACKAGE__->mk_accessors(qw/ parent transformer_type /);

__PACKAGE__->mk_output_accessors(qw/ message /);

sub new {
    my $class = shift;

    my %attrs;
    eval { %attrs = %{ $_[0] } if @_ };
    croak "attributes argument must be a hashref" if $@;

    my $self = bless {}, $class;

    for (qw/ transformer_type /) {
        croak "$_ attribute required" if !exists $attrs{$_};
    }

    $self->populate( \%attrs );

    return $self;
}

sub process {
    my ( $self, $params ) = @_;

    my $name  = $self->name;
    my $value = $params->{$name};
    my @errors;

    if ( ref $value ) {
        eval { my @x = @$value };
        croak $@ if $@;

        push @errors, eval {
            $self->validate_values( $value, $params );
        };
        if ( blessed $@ && $@->isa('HTML::FormFu::Exception::Transformer') ) {
            push @errors, $@;
        }
        elsif ( $@ ) {
            push @errors, HTML::FormFu::Exception::Transformer->new;
        }
    }
    else {
        my $ok = eval {
            $self->validate_value( $value, $params ) ? 1 : 0;
        };
        if ( blessed $@ && $@->isa('HTML::FormFu::Exception::Transformer') ) {
            push @errors, $@;
        }
        elsif ( $@ or !$ok ) {
            push @errors, HTML::FormFu::Exception::Transformer->new;
        }
    }

    return @errors;
}

sub validate_values {
    my ( $self, $values, $params ) = @_;

    my @errors;

    for my $value (@$values) {
        my $ok = eval {
            $self->validate_value( $value, $params ) ? 1 : 0;
        };
        if ( blessed $@ && $@->isa('HTML::FormFu::Exception::Transformer') ) {
            push @errors, $@;
        }
        elsif ( $@ or !$ok ) {
            push @errors, HTML::FormFu::Exception::Transformer->new;
        }
    }

    return @errors;
}

sub validate_value {
    croak "validate() should be overridden";
}

sub clone {
    my ( $self ) = @_;
    
    my %new = %$self;
    
    return bless \%new, ref $self;
}

1;

__END__

=head1 NAME

HTML::Widget::Transformer - Transformer Base Class

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head1 CORE TRANSFORMERS

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
