package HTML::FormFu::Plugin;

use strict;
use Class::C3;

use HTML::FormFu::Attribute qw( mk_item_accessors mk_accessors );
use HTML::FormFu::ObjectUtil qw( populate form parent );
use Scalar::Util qw( refaddr );
use Carp qw( croak );

use overload
    'eq' => sub { refaddr $_[0] eq refaddr $_[1] },
    '==' => sub { refaddr $_[0] eq refaddr $_[1] },
    bool => sub {1},
    fallback => 1;

__PACKAGE__->mk_item_accessors( qw( type ) );

sub new {
    my $class = shift;

    my %attrs;
    eval { %attrs = %{ $_[0] } if @_ };
    croak "attributes argument must be a hashref" if $@;

    my $self = bless {}, $class;

    for (qw( type )) {
        croak "$_ attribute required" if !exists $attrs{$_};
    }

    if ( exists $attrs{parent} ) {
        $self->parent( delete $attrs{parent} );
    }

    $self->populate( \%attrs );

    return $self;
}

sub process { }

sub post_process { }

sub render { }

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

=head2 DESCRIPTION

Plugins can be added to a form or any element to modify their behaviour.
Some plugins should only be added to either a form, or an element, depending
on their design.

=head1 METHODS

Plugins can override any of the following method stubs.

=head2 process

Only plugins added to a form or a field element inheriting from
L<HTML::FormFu::Element::_Field> will have their C<process> method run.

For form plugins, is called during L<HTML::FormFu/process>, before C<process>
is called on any elements.

For field plugins, is called during the field's C<process> call.

=head2 post_process

For form plugins, is called immediately before L<HTML::FormFu/process>
returns.

For element plugins, is called before C<post_process> is run on form plugins.

=head2 render

Only plugins added to a form will have their C<render> method run.

Is called during L<HTML::FormFu/render> before the
L<HTML::FormFu/render_method> is called.

=head2 post_render

Only plugins added to a form will have their C<post_render> method run.

Is called during L<HTML::FormFu/render> immediately before
L<HTML::FormFu/render> return.

Is passed a reference to the return value of L<HTML::FormFu/render_method>.

=head1 CORE PLUGINS

=over

=item L<HTML::FormFu::Plugin::StashValid>

=back

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
