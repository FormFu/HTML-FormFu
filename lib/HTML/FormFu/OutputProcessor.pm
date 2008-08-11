package HTML::FormFu::OutputProcessor;

use strict;
use Class::C3;

use HTML::FormFu::Attribute qw( mk_accessors );
use HTML::FormFu::ObjectUtil qw( populate form parent );
use Carp qw/ croak /;

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

sub clone {
    my ($self) = @_;

    my %new = %$self;

    return bless \%new, ref $self;
}

1;

__END__

=head1 NAME

HTML::FormFu::OutputProcessor - Post-process HTML output

=head1 DESCRIPTION

Post-process a form or element's HTML.

=head1 CORE OUTPUT PROCESSORS

=over

=item L<HTML::FormFu::OutputProcessor::Indent>

=item L<HTML::FormFu::OutputProcessor::StripWhitespace>

=back

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
