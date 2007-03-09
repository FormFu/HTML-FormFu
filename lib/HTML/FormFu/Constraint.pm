package HTML::FormFu::Constraint;

use strict;
use warnings;
use base 'Class::Accessor::Chained::Fast';

use HTML::FormFu::Accessor qw( mk_output_accessors );
use HTML::FormFu::Error;
use HTML::FormFu::ObjectUtil qw( populate localize form name );
use Scalar::Util qw/ weaken /;
use Carp qw/ croak /;

__PACKAGE__->mk_accessors(qw/ parent constraint_type not /);

__PACKAGE__->mk_output_accessors(qw/ message /);

*loc = \&localize;

sub new {
    my $class = shift;

    my %attrs;
    eval { %attrs = %{ $_[0] } if @_ };
    croak "attributes argument must be a hashref" if $@;

    my $self = bless {}, $class;

    for (qw/ constraint_type /) {
        croak "$_ attribute required" if !exists $attrs{$_};
    }

    $self->populate( \%attrs );

    return $self;
}

sub process {
    my ( $self, $form_result, $params ) = @_;

    my $name  = $self->name;
    my $value = $params->{$name};
    my @pass;

    if ( ref $value ) {
        eval { my @x = @$value };
        croak $@ if $@;

        push @pass, $self->validate_values( $value, $params );
    }
    else {
        push @pass, $self->validate_value( $value, $params ) ? 1 : 0;
    }

    my @errors;

    push @errors, $self->error( { name => $name } )
        if grep { !$_ } @pass;

    return \@errors;
}

sub validate_values {
    my ( $self, $values, $params ) = @_;

    my @results;

    for my $value (@$values) {
        push @results, $self->validate_value( $value, $params ) ? 1 : 0;
    }

    return @results;
}

sub validate_value {
    croak "validate() should be overridden";
}

sub error {
    my ( $self, $args, @loc_args ) = @_;

    croak "name attribute required" if !exists $args->{name};

    $args->{type}   = $self->constraint_type if !exists $args->{type};

    if ( !exists $args->{message} ) {
        $args->{message} =
            defined $self->message
            ? $self->message
            : $self->mk_message(@loc_args);
    }

    my $error = HTML::FormFu::Error->new($args);
    
    $error->parent( $self->parent );
    weaken( $error->{parent} );
    
    return $error;
}

sub mk_message {
    my ( $self, @args ) = @_;

    my $string = $self->message;

    $string = 'form_' . lc $self->constraint_type . '_error'
        if !defined $string;

    return $self->localize( $string, @args );
}

sub clone {
    my ( $self ) = @_;
    
    my %new = %$self;
    
    return bless \%new, ref $self;
}

1;

__END__

=head1 NAME

HTML::Widget::Constraint - Constraint Base Class

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head1 CORE CONSTRAINTS

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

Based on the original source code of L<HTML::Widget::Constraint>, by 
Sebastian Riedel, C<sri@oook.de>.

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
