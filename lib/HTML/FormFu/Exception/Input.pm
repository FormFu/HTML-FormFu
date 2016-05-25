package HTML::FormFu::Exception::Input;

use strict;
# VERSION

use Moose;
use MooseX::Attribute::FormFuChained;
extends 'HTML::FormFu::Exception';

use HTML::FormFu::Attribute qw( mk_attrs );
use HTML::FormFu::Util qw( append_xml_attribute literal xml_escape );

has processor => ( is => 'rw', traits => ['FormFuChained'] );
has forced    => ( is => 'rw', traits => ['FormFuChained'] );

__PACKAGE__->mk_attrs(qw( attributes ));

sub BUILD {
    my ( $self, $args ) = @_;

    $self->attributes({});

    return;
}

sub name {
    my ($self) = @_;

    return $self->parent->name;
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

    $error_message = $self->form->localize( $error_message,
        $self->processor->localize_args );

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

around render_data_non_recursive => sub {
    my ( $orig, $self, $args ) = @_;

    my $render = $self->$orig( {
            processor => $self->processor,
            forced    => $self->forced,
            name      => $self->name,
            message   => $self->message,
            type      => $self->type,
            $args ? %$args : (),
        });

    $self->_render_attributes($render);

    return $render;
};

sub _render_attributes {
    my ( $self, $render ) = @_;

    my $attrs = xml_escape( $self->attributes );

    my $auto_error_class = $self->parent->auto_error_class;

    if ( defined $auto_error_class ) {
        my %string = (
            f => defined $self->form->id ? $self->form->id   : '',
            n => defined $self->name     ? $self->name       : '',
            t => defined $self->type     ? lc( $self->type ) : '',
            s => $self->stage,
        );

        $string{t} =~ s/::/_/g;
        $string{t} =~ s/\+//;

        $auto_error_class =~ s/%([fnts])/$string{$1}/g;

        append_xml_attribute( $attrs, 'class', $auto_error_class );
    }

    $render->{attributes} = $attrs;
}

__PACKAGE__->meta->make_immutable;

1;
