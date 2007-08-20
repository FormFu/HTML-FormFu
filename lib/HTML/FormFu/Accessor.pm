package HTML::FormFu::Accessor;

use strict;
use warnings;
use Exporter qw/ import /;

use HTML::FormFu::Util qw( append_xml_attribute literal );
use Carp qw/ croak /;

our @EXPORT_OK = qw/
    mk_inherited_accessors
    mk_output_accessors
    mk_inherited_merging_accessors
    /;

sub mk_inherited_accessors {
    my ( $self, @names ) = @_;

    my $class = ref $self || $self;

    for my $name (@names) {
        my $sub = sub {
            my $self = shift;
            if (@_) {
                $self->{$name} = $_[0];
                return $self;
            }
            while ( defined $self->parent && !defined $self->{$name} ) {
                $self = $self->parent;
            }
            return $self->{$name};
        };
        no strict 'refs';
        *{"$class\::$name"} = $sub;
    }

    return;
}

sub mk_inherited_merging_accessors {
    my ( $self, @names ) = @_;

    my $class = ref $self || $self;

    $class->mk_inherited_accessors(@names);

    for my $name (@names) {
        my $sub = sub {
            my $self = shift;
            if (@_) {
                my %attrs = ( @_ == 1 ) ? %{ $_[0] } : @_;

                for ( keys %attrs ) {
                    append_xml_attribute( $self->{$name}, $_, $attrs{$_} );
                }
                return $self;
            }
            while ( defined $self->parent && !defined $self->{$name} ) {
                $self = $self->parent;
            }
            return $self->{$name};
        };
        no strict 'refs';
        *{"$class\::add_$name"} = $sub;
    }

    return;
}

sub mk_output_accessors {
    my ( $self, @names ) = @_;

    my $class = ref $self || $self;

    for my $name (@names) {
        my $sub = sub {
            my $self = shift;
            if (@_) {
                $self->{$name} = $_[0];
                return $self;
            }
            return $self->{$name};
        };
        my $xml_sub = sub {
            my ( $self, $arg ) = @_;

            return $self->$name( literal($arg) );
        };
        my $loc_sub = sub {
            my ( $self, $mess, @args ) = @_;

            return $self->$name(
                literal( $self->form->localize( $mess, @args ) ) );
        };
        no strict 'refs';
        *{"$class\::$name"}       = $sub;
        *{"$class\::${name}_xml"} = $xml_sub;
        *{"$class\::${name}_loc"} = $loc_sub;
    }

    return;
}

1;

__END__

=head1 NAME

HTML::FormFu::Accessor

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head1 AUTHOR

Carl Franks, C<cfranks.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
