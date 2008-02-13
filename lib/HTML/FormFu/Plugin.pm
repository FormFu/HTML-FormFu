package HTML::FormFu::Plugin;

use strict;
use Class::C3;

use HTML::FormFu::Attribute qw/ mk_accessors /;
use HTML::FormFu::ObjectUtil qw( populate form parent );
use Scalar::Util qw/ refaddr /;
use Carp qw/ croak /;

use overload
    'eq' => sub { refaddr $_[0] eq refaddr $_[1] },
    '==' => sub { refaddr $_[0] eq refaddr $_[1] },
    bool => sub {1},
    fallback => 1;

__PACKAGE__->mk_accessors(qw/ type /);

sub new {
    my $class = shift;

    my %attrs;
    eval { %attrs = %{ $_[0] } if @_ };
    croak "attributes argument must be a hashref" if $@;

    my $self = bless {}, $class;

    for (qw/ type /) {
        croak "$_ attribute required" if !exists $attrs{$_};
    }

    if ( exists $attrs{parent} ) {
        $self->parent( delete $attrs{parent} );
    }

    $self->populate( \%attrs );

    return $self;
}

sub pre_process { }

sub post_process { }

sub pre_render { }

sub post_render { }

sub clone {
    my ($self) = @_;

    my %new = %$self;

    return bless \%new, ref $self;
}

1;

__END__

=head1 NAME

HTML::FormFu::Plugin - base class for plugins

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
