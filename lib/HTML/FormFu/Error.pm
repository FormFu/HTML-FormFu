package HTML::FormFu::Error;

use strict;
use warnings;

use base 'Class::Accessor::Chained::Fast';

use HTML::FormFu::Accessor qw( mk_output_accessors );
use HTML::FormFu::ObjectUtil qw( localize form );
use Class::Data::Accessor;
use Carp qw/ croak /;

__PACKAGE__->Class::Data::Accessor::mk_classaccessor(
    default_type => 'Custom' );

__PACKAGE__->mk_accessors(qw/ name type class parent /);

__PACKAGE__->mk_output_accessors(qw/ message /);

*loc = \&localize;

sub new {
    my ( $class, $attrs ) = @_;

    my %attrs;
    eval { %attrs = %$attrs if defined $attrs; };
    croak "attrs must be a hashref" if $@;

    croak "name attribute required" if !exists $attrs{name};

    my $self = bless \%attrs, $class;

    $self->type( $self->default_type )
        if !defined $self->type;

    $self->class( lc( $self->type ) . "_error" )
        if !defined $self->class;

    return $self;
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
