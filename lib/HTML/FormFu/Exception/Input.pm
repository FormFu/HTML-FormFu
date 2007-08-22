package HTML::FormFu::Exception::Input;

use strict;
use base 'HTML::FormFu::Exception';

use HTML::FormFu::Util qw( literal );

__PACKAGE__->mk_accessors(qw/ processor forced /);

sub name {
    my $self = shift;

    return $self->parent->name;
}

sub class {
    my $self = shift;

    if (@_) {
        return $self->{class} = shift;
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

    my $class = $self->parent->auto_error_class;

    $class =~ s/%([fnts])/$string{$1}/g;

    return $self->{class} = $class;
}

sub message {
    my $self = shift;

    if (@_) {
        return $self->{message} = shift;
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

    my $message = $self->parent->auto_error_message;

    $message =~ s/%([fnts])/$string{$1}/g;

    return $self->{message}
        = $self->form->localize( $message, $self->processor->localize_args );
}

sub type {
    my $self = shift;

    return $self->processor->type;
}

sub clone {
    my ($self) = @_;

    my %new = %$self;

    return bless \%new, ref $self;
}

1;
