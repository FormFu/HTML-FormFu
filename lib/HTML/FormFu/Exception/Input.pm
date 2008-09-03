package HTML::FormFu::Exception::Input;

use strict;
use base 'HTML::FormFu::Exception';

use HTML::FormFu::Util qw( literal );

__PACKAGE__->mk_item_accessors( qw( processor forced ) );

sub name {
    my ($self) = @_;

    return $self->parent->name;
}

sub class {
    my ( $self, $class ) = @_;

    if ( @_ > 1 ) {
        return $self->{class} = $class;
    }

    return $self->{class} if defined $self->{class};

    my %string = (
        f => defined $self->form->id ? $self->form->id   : '',
        n => defined $self->name     ? $self->name       : '',
        t => defined $self->type     ? lc( $self->type ) : '',
        s => $self->stage,
    );

    $string{t} =~ s/::/_/g;
    $string{t} =~ s/\+//;

    my $error_class = $self->parent->auto_error_class;

    $error_class =~ s/%([fnts])/$string{$1}/g;

    return $self->{class} = $error_class;
}

sub message {
    my ( $self, $message ) = @_;

    if ( @_ > 1 ) {
        return $self->{message} = $message;
    }

    return $self->{message} if defined $self->{message};

    return $self->processor->message if defined $self->processor->message;

    my %string = (
        f => defined $self->form->id ? $self->form->id   : '',
        n => defined $self->name     ? $self->name       : '',
        t => defined $self->type     ? lc( $self->type ) : '',
        s => $self->stage,
    );

    $string{t} =~ s/::/_/g;
    $string{t} =~ s/\+//;

    my $error_message = $self->parent->auto_error_message;

    $error_message =~ s/%([fnts])/$string{$1}/g;

    $error_message = $self->form->localize(
        $error_message,
        $self->processor->localize_args
    );

    return $self->{message} = $error_message;
}

sub type {
    my ($self) = @_;

    return $self->processor->type;
}

sub clone {
    my ($self) = @_;

    my %new = %$self;

    return bless \%new, ref $self;
}

1;
