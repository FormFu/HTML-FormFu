use strict;

package HTML::FormFu::Role::ContainsElementsSharedWithField;

use Moose::Role;

use HTML::FormFu::Util qw(
    require_class
    _merge_hashes
);
use Carp qw( croak );

sub get_error {
    my $self = shift;

    return if !$self->form->submitted;

    my $c = $self->get_errors(@_);

    return @$c ? $c->[0] : ();
}

sub _require_constraint {
    my ( $self, $type, $arg ) = @_;

    croak 'required arguments: $self, $type, \%options' if @_ != 3;

    eval { my %x = %$arg };
    croak "options argument must be hash-ref" if $@;

    my $abs = $type =~ s/^\+//;
    my $not = 0;

    if ( $type =~ /^Not_(\w+)$/i ) {
        $type = $1;
        $not  = 1;
    }

    my $class = $type;

    if ( !$abs ) {
        $class = "HTML::FormFu::Constraint::$class";
    }

    $type =~ s/^\+//;

    require_class($class);

    my $constraint = $class->new(
        {   type   => $type,
            not    => $not,
            parent => $self,
        } );

    # handle default_args
    my $parent = $self->parent;

    if ( exists $parent->default_args->{constraints}{$type} ) {
        $arg = _merge_hashes( $parent->default_args->{constraints}{$type}, $arg,
        );
    }

    $constraint->populate($arg);

    return $constraint;
}

1;
