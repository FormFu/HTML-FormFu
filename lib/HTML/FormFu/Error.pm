package HTML::FormFu::Error;

use strict;
use warnings;

use base 'Class::Accessor::Chained::Fast';

use HTML::FormFu::Accessor qw( mk_output_accessors );
use HTML::FormFu::ObjectUtil qw( form );
use HTML::FormFu::Util qw( literal );
use Class::Data::Accessor;
use Carp qw/ croak /;

__PACKAGE__->Class::Data::Accessor::mk_classaccessor(
    default_type => 'Custom' );

__PACKAGE__->mk_accessors(qw/ name type parent /);

sub new {
    my ( $class, $attrs ) = @_;

    my %attrs;
    eval { %attrs = %$attrs if defined $attrs; };
    croak "attrs must be a hashref" if $@;

    croak "name attribute required" if !exists $attrs{name};

    my $self = bless \%attrs, $class;

    $self->type( $self->default_type )
        if !defined $self->type;

    return $self;
}

sub message {
    my $self = shift;
    
    if (@_) {
        return $self->{message} = shift;
    }
    
    return $self->{message} if defined $self->{message};
    
    my %string = (
        f => defined $self->form->id    ? $self->form->id    : '',
        n => defined $self->field->name ? $self->field->name : '',
        t => defined $self->type        ? lc( $self->type )  : '',
    );
    
    my $message = $self->field->auto_error_message;
    
    $message =~ s/%([fnt])/$string{$1}/ge;;
    
    return $self->{message} = $self->form->localize( $message );
}

sub message_xml {
    my $self = shift;
    
    return $self->message(@_);
}

sub message_loc {
    my ( $self, $mess, @args ) = @_;
    
    return $self->message( literal( $self->form->localize( $mess, @args ) ) );
}

sub class {
    my $self = shift;
    
    if (@_) {
        return $self->{class} = shift;
    }
    
    return $self->{class} if defined $self->{class};
    
    my %string = (
        f => defined $self->form->id    ? $self->form->id    : '',
        n => defined $self->field->name ? $self->field->name : '',
        t => defined $self->type        ? lc( $self->type )  : '',
    );
    
    my $class = $self->field->auto_error_class;
    
    $class =~ s/%([fnt])/$string{$1}/ge;
    
    return $self->{class} = $class;
}

sub field {
    my $self = shift;
    
    # errors are a child of a constraint
    # constraints are a child of a field
    
    return $self->parent->parent;
}

1;

__END__

=head1 NAME

HTML::Widget::Error - Error

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
