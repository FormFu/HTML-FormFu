package HTML::FormFu::Exception::Input;

use strict;
use warnings;
use base 'HTML::FormFu::Exception';

use HTML::FormFu::Util qw( literal );

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
    
    my $class = $self->parent->auto_error_class;
    
    $class =~ s/%([fnts])/$string{$1}/ge;
    
    return $self->{class} = $class;
}

sub message {
    my $self = shift;
    
    if (@_) {
        return $self->{message} = shift;
    }
    
    return $self->{message} if defined $self->{message};
    
    my $stage = $self->stage;
    return $self->$stage->message if defined $self->$stage->message;
    
    my %string = (
        f => defined $self->form->id ? $self->form->id   : '',
        n => defined $self->name     ? $self->name       : '',
        t => defined $self->type     ? lc( $self->type ) : '',
    );
    
    my $message = $self->parent->auto_error_message;
    
    $message =~ s/%([fnt])/$string{$1}/ge;;
    
    return $self->{message} = $self->form->localize( $message );
}

1;
