package HTML::FormFu::Attribute;

use strict;
use warnings;
use Exporter qw( import );
use Carp qw( croak );
use Class::MOP::Method;
use HTML::FormFu::Util qw(
    append_xml_attribute remove_xml_attribute literal
    _parse_args );

our @EXPORT_OK = qw(
    mk_attrs                        mk_attr_accessors
    mk_attr_modifiers               mk_inherited_accessors
    mk_output_accessors             mk_inherited_merging_accessors
    mk_attr_bool_accessors
);

sub mk_attrs {
    my ( $self, @names ) = @_;

    my $class = ref $self || $self;

    for my $name (@names) {
        my $sub = sub {
            my ( $self, $attrs ) = @_;

            if ( !exists $self->{$name} ) {
                $self->{$name} = {};
            }

            return $self->{$name} if @_ == 1;

            my $attr_slot = $self->{$name};

            while ( my ( $key, $value ) = each %$attrs ) {
                $attr_slot->{$key} = $value;
            }

            return $self;
        };

        my $method = Class::MOP::Method->wrap(
            body         => $sub,
            name         => $name,
            package_name => $class,
        );

        my $xml_sub = sub {
            my ( $self, $attrs ) = @_;

            return $self->$name( {
                    map { $_, literal( $attrs->{$_} ) }
                        keys %$attrs
                } );
        };

        my $xml_method = Class::MOP::Method->wrap(
            body         => $xml_sub,
            name         => "${name}_xml",
            package_name => $class,
        );

        $class->meta->add_method( $name,         $method );
        $class->meta->add_method( "${name}_xml", $xml_method );

        my $loc_sub = sub {
            my ( $self, $mess, @args ) = @_;

            if ( ref $mess eq 'ARRAY' ) {
                ( $mess, @args ) = ( @$mess, @args );
            }

            return $self->$name(
                literal( $self->form->localize( $mess, @args ) ) );
        };

        my $loc_method = Class::MOP::Method->wrap(
            body         => $loc_sub,
            name         => "${name}_loc",
            package_name => $class,
        );

        # add shortcuts
        my $short = $name;
        if ( $short =~ s/attributes$/attrs/ ) {

            my $method = Class::MOP::Method->wrap(
                body         => $sub,
                name         => $short,
                package_name => $class,
            );

            my $xml_method = Class::MOP::Method->wrap(
                body         => $xml_sub,
                name         => "${short}_xml",
                package_name => $class,
            );

            my $loc_method = Class::MOP::Method->wrap(
                body         => $loc_sub,
                name         => "${short}_loc",
                package_name => $class,
            );

            $class->meta->add_method( $short,         $method );
            $class->meta->add_method( "${short}_xml", $xml_method );
            $class->meta->add_method( "${short}_loc", $loc_method );
        }
    }

    mk_add_attrs( $class, @names );
    mk_del_attrs( $class, @names );

    return;
}

sub mk_attr_accessors {
    my ( $self, @names ) = @_;

    my $class = ref $self || $self;

    for my $name (@names) {
        my $sub = sub {
            my ( $self, $attr ) = @_;

            return $self->attributes->{$name} if @_ == 1;

            $self->attributes->{$name} = $attr;

            return $self;
        };

        my $method = Class::MOP::Method->wrap(
            body         => $sub,
            name         => $name,
            package_name => $class,
        );

        my $xml_sub = sub {
            my ( $self, $value ) = @_;

            return $self->attributes->{$name} = literal $value;
        };

        my $xml_method = Class::MOP::Method->wrap(
            body         => $xml_sub,
            name         => "${name}_xml",
            package_name => $class,
        );

        my $loc_sub = sub {
            my ( $self, $mess, @args ) = @_;

            if ( ref $mess eq 'ARRAY' ) {
                ( $mess, @args ) = ( @$mess, @args );
            }

            return $self->attributes->{$name} =
                literal( $self->form->localize( $mess, @args ) );
        };

        my $loc_method = Class::MOP::Method->wrap(
            body         => $loc_sub,
            name         => "${name}_loc",
            package_name => $class,
        );

        $class->meta->add_method( $name,         $method );
        $class->meta->add_method( "${name}_xml", $xml_method );
        $class->meta->add_method( "${name}_loc", $loc_method );
    }

    return;
}

sub mk_add_attrs {
    my ( $self, @names ) = @_;

    my $class = ref $self || $self;

    for my $name (@names) {
        my $sub = sub {
            my ( $self, $attrs ) = @_;

            while ( my ( $key, $value ) = each %$attrs ) {
                append_xml_attribute( $self->{$name}, $key, $value );
            }
            return $self;
        };

        my $method = Class::MOP::Method->wrap(
            body         => $sub,
            name         => "add_$name",
            package_name => $class,
        );

        my $xml_sub = sub {
            my ( $self, $attrs ) = @_;

            my $method = "add_$name";

            return $self->$method( {
                    map { $_, literal( $attrs->{$_} ) }
                        keys %$attrs
                } );
        };

        my $xml_method = Class::MOP::Method->wrap(
            body         => $xml_sub,
            name         => "add_${name}_xml",
            package_name => $class,
        );

        my $loc_sub = sub {
            my ( $self, $mess, @args ) = @_;

            if ( ref $mess eq 'ARRAY' ) {
                ( $mess, @args ) = ( @$mess, @args );
            }

            return $self->$method(
                literal( $self->form->localize( $mess, @args ) ) );
        };

        my $loc_method = Class::MOP::Method->wrap(
            body         => $loc_sub,
            name         => "add_${name}_loc",
            package_name => $class,
        );

        $class->meta->add_method( "add_$name",       $method );
        $class->meta->add_method( "add_${name}_xml", $xml_method );
        $class->meta->add_method( "add_${name}_loc", $loc_method );

        # add shortcuts
        my $short = $name;
        if ( $short =~ s/attributes$/attrs/ ) {

            my $method = Class::MOP::Method->wrap(
                body         => $sub,
                name         => "add_$short",
                package_name => $class,
            );

            my $xml_method = Class::MOP::Method->wrap(
                body         => $xml_sub,
                name         => "add_${short}_xml",
                package_name => $class,
            );

            my $loc_method = Class::MOP::Method->wrap(
                body         => $loc_sub,
                name         => "add_${short}_loc",
                package_name => $class,
            );

            $class->meta->add_method( "add_$short",       $method );
            $class->meta->add_method( "add_${short}_xml", $xml_method );
            $class->meta->add_method( "add_${short}_loc", $loc_method );
        }
    }

    return;
}

sub mk_del_attrs {
    my ( $self, @names ) = @_;

    my $class = ref $self || $self;

    for my $name (@names) {
        my $sub = sub {
            my ( $self, $attrs ) = @_;

            while ( my ( $key, $value ) = each %$attrs ) {
                remove_xml_attribute( $self->{$name}, $key, $value );
            }
            return $self;
        };

        my $method = Class::MOP::Method->wrap(
            body         => $sub,
            name         => "del_$name",
            package_name => $class,
        );

        my $xml_sub = sub {
            my ( $self, $attrs ) = @_;

            my $method = "del_$name";

            return $self->$method( {
                    map { $_, literal( $attrs->{$_} ) }
                        keys %$attrs
                } );
        };

        my $xml_method = Class::MOP::Method->wrap(
            body         => $xml_sub,
            name         => "del_${name}_xml",
            package_name => $class,
        );

        my $loc_sub = sub {
            my ( $self, $mess, @args ) = @_;

            if ( ref $mess eq 'ARRAY' ) {
                ( $mess, @args ) = ( @$mess, @args );
            }

            return $self->$method(
                literal( $self->form->localize( $mess, @args ) ) );
        };

        my $loc_method = Class::MOP::Method->wrap(
            body         => $loc_sub,
            name         => "del_${name}_loc",
            package_name => $class,
        );

        $class->meta->add_method( "del_$name",       $method );
        $class->meta->add_method( "del_${name}_xml", $xml_method );
        $class->meta->add_method( "del_${name}_loc", $loc_method );

        # add shortcuts
        my $short = $name;
        if ( $short =~ s/attributes$/attrs/ ) {

            my $method = Class::MOP::Method->wrap(
                body         => $sub,
                name         => "del_$short",
                package_name => $class,
            );

            my $xml_method = Class::MOP::Method->wrap(
                body         => $xml_sub,
                name         => "del_${short}_xml",
                package_name => $class,
            );

            my $loc_method = Class::MOP::Method->wrap(
                body         => $loc_sub,
                name         => "del_${short}_loc",
                package_name => $class,
            );

            $class->meta->add_method( "del_$short",       $method );
            $class->meta->add_method( "del_${short}_xml", $xml_method );
            $class->meta->add_method( "del_${short}_loc", $loc_method );
        }
    }

    return;
}

sub mk_inherited_accessors {
    my ( $self, @names ) = @_;

    my $class = ref $self || $self;

    for my $name (@names) {
        my $sub = sub {
            my ( $self, $value ) = @_;

            if ( @_ > 1 ) {
                $self->{$name} = $value;
                return $self;
            }

            # micro optimization! this method's called a lot, so access
            # parent hashkey directly, instead of calling parent()
            while ( defined( my $parent = $self->{parent} )
                && !defined $self->{$name} )
            {
                $self = $parent;
            }
            return $self->{$name};
        };

        my $no_inherit_sub = sub {
            my ( $self, $value ) = @_;

            if ( @_ > 1 ) {
                croak "Cannot call ${name}_no_inherit as a setter";
            }

            return $self->{$name};
        };

        my $method = Class::MOP::Method->wrap(
            body         => $sub,
            name         => $name,
            package_name => $class,
        );

        my $no_inherit_method = Class::MOP::Method->wrap(
            body         => $no_inherit_sub,
            name         => "${name}_no_inherit",
            package_name => $class,
        );

        $class->meta->add_method( $name, $method );
        $class->meta->add_method( "${name}_no_inherit", $no_inherit_method );
    }

    return;
}

sub mk_inherited_merging_accessors {
    my ( $self, @names ) = @_;

    my $class = ref $self || $self;

    $class->mk_inherited_accessors(@names);

    for my $name (@names) {
        my $sub = sub {
            my ( $self, $attrs ) = @_;

            if (@_) {
                while ( my ( $key, $value ) = each %$attrs ) {
                    append_xml_attribute( $self->{$name}, $key, $value );
                }
                return $self;
            }

            # micro optimization! this method's called a lot, so access
            # parent hashkey directly, instead of calling parent()
            while ( defined( my $parent = $self->{parent} )
                && !defined $self->{$name} )
            {
                $self = $parent;
            }
            return $self->{$name};
        };

        my $method = Class::MOP::Method->wrap(
            body         => $sub,
            name         => "add_$name",
            package_name => $class,
        );

        $class->meta->add_method( "add_$name", $method );
    }

    return;
}

sub mk_output_accessors {
    my ( $self, @names ) = @_;

    my $class = ref $self || $self;

    for my $name (@names) {
        my $sub = sub {
            my ( $self, $value ) = @_;
            if ( @_ > 1 ) {
                $self->{$name} = $value;
                return $self;
            }
            return $self->{$name};
        };

        my $method = Class::MOP::Method->wrap(
            body         => $sub,
            name         => $name,
            package_name => $class,
        );

        my $xml_sub = sub {
            my ( $self, $arg ) = @_;

            return $self->$name( literal($arg) );
        };

        my $xml_method = Class::MOP::Method->wrap(
            body         => $xml_sub,
            name         => "${name}_xml",
            package_name => $class,
        );

        my $loc_sub = sub {
            my ( $self, $mess, @args ) = @_;

            if ( ref $mess eq 'ARRAY' ) {
                ( $mess, @args ) = ( @$mess, @args );
            }

            return $self->$name(
                literal( $self->form->localize( $mess, @args ) ) );
        };

        my $loc_method = Class::MOP::Method->wrap(
            body         => $loc_sub,
            name         => "${name}_loc",
            package_name => $class,
        );

        $class->meta->add_method( $name,         $method );
        $class->meta->add_method( "${name}_xml", $xml_method );
        $class->meta->add_method( "${name}_loc", $loc_method );
    }

    return;
}

sub mk_attr_bool_accessors {
    my ( $self, @names ) = @_;

    my $class = ref $self || $self;

    for my $name (@names) {
        my $sub = sub {
            my ( $self, $attr ) = @_;

            if ( @_ == 1 ) {
                # Getter
                return undef if !exists $self->attributes->{$name};

                return $self->attributes->{$name} ? $self->attributes->{$name}
                                                  : undef;
            }

            # Any true value sets a bool attribute, e.g.
            #     required="required"
            # Any false value deletes the attribute

            if ( $attr ) {
                $self->attributes->{$name} = $name;
            }
            else {
                delete $self->attributes->{$name};
            }

            return $self;
        };

        my $method = Class::MOP::Method->wrap(
            body         => $sub,
            name         => $name,
            package_name => $class,
        );

        $class->meta->add_method( $name,         $method );
    }

    return;
}


1;

__END__

=head1 NAME

HTML::FormFu::Attribute - accessor class

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head1 AUTHOR

Carl Franks, C<cfranks@cpan.org>

Based on the original source code of L<HTML::Widget::Accessor>, by 
Sebastian Riedel, C<sri@oook.de>.

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
