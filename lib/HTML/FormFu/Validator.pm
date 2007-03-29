package HTML::FormFu::Validator;

use strict;
use warnings;
use base 'Class::Accessor::Chained::Fast';

use HTML::FormFu::Accessor qw( mk_output_accessors );
use HTML::FormFu::Exception::Validator;
use HTML::FormFu::ObjectUtil qw( populate form name );
use Scalar::Util qw/ blessed /;
use Carp qw/ croak /;

__PACKAGE__->mk_accessors(qw/ parent validator_type localize_args /);

__PACKAGE__->mk_output_accessors(qw/ message /);

sub new {
    my $class = shift;

    my %attrs;
    eval { %attrs = %{ $_[0] } if @_ };
    croak "attributes argument must be a hashref" if $@;

    my $self = bless {}, $class;

    for (qw/ validator_type /) {
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

    if ( ref $value eq 'ARRAY' ) {
        eval { my @x = @$value };
        croak $@ if $@;

        push @errors, eval {
            $self->validate_values( $value, $params );
        };
        if ( $@ ) {
            push @errors, $self->return_error($@);
        }
    }
    else {
        my $ok = eval {
            $self->validate_value( $value, $params );
        };
        if ( $@ or !$ok ) {
            push @errors, $self->return_error($@);
        }
    }

    return @errors;
}

sub validate_values {
    my ( $self, $values, $params ) = @_;

    my @errors;

    for my $value (@$values) {
        my $ok = eval {
            $self->validate_value( $value, $params );
        };
        if ( blessed $@ && $@->isa('HTML::FormFu::Exception::Validator') ) {
            push @errors, $@;
        }
        elsif ( $@ or !$ok ) {
            push @errors, HTML::FormFu::Exception::Validator->new;
        }
    }

    return @errors;
}

sub validate_value {
    croak "validate() should be overridden";
}

sub return_error {
    my ( $self, $err ) = @_;
    
    if ( !blessed $err || !$err->isa('HTML::FormFu::Exception::Validator') ) {
        $err = HTML::FormFu::Exception::Validator->new;
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

HTML::FormFu::Validator - Validator Base Class

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head1 CORE VALIDATORS

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
