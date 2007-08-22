package HTML::FormFu::Attribute;

use strict;
use warnings;
use Exporter qw/ import /;
use HTML::FormFu::Util qw/
    append_xml_attribute remove_xml_attribute literal require_class
    _parse_args /;
use List::MoreUtils qw/ uniq /;
use Scalar::Util qw/ weaken /;
use Carp qw/ croak /;

our @EXPORT_OK = qw/ mk_attrs mk_attr_accessors mk_attr_modifiers
    mk_add_methods mk_single_methods mk_require_methods mk_get_methods
    mk_get_one_methods mk_inherited_accessors mk_output_accessors 
    mk_inherited_merging_accessors /;

sub mk_attrs {
    my ( $self, @names ) = @_;

    my $class = ref $self || $self;

    for my $name (@names) {
        my $sub = sub {
            my $self = shift;

            $self->{$name} = {} if not exists $self->{$name};

            return $self->{$name} unless @_;

            my %attrs = ( @_ == 1 ) ? %{ $_[0] } : @_;

            $self->{$name}->{$_} = $attrs{$_} for keys %attrs;

            return $self;
        };
        my $xml_sub = sub {
            my $self = shift;
            my %attrs = ( @_ == 1 ) ? %{ $_[0] } : @_;

            return $self->$name(
                map { ( $_, literal( $attrs{$_} ) ) }
                    keys %attrs
            );
        };
        no strict 'refs';
        *{"$class\::$name"}       = $sub;
        *{"$class\::${name}_xml"} = $xml_sub;

        # add shortcuts
        my $short = $name;
        if ( $short =~ s/attributes$/attrs/ ) {
            *{"$class\::$short"}       = $sub;
            *{"$class\::${short}_xml"} = $xml_sub;
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
            return ( $_[0]->attributes->{$name} ) unless @_ > 1;
            my $self = shift;
            $self->attributes->{$name} = $_[0];
            return $self;
        };
        my $xml_sub = sub {
            my $self = shift;
            my @args;

            for my $item (@_) {
                if ( ref $item eq 'HASH' ) {
                    push @args, { map { $_, literal($_) } keys %$item };
                }
                elsif ( ref $item eq 'ARRAY' ) {
                    push @args, [ map { literal($_) } @$item ];
                }
                else {
                    push @args, literal($item);
                }
            }
            return $self->$name(@args);
        };
        no strict 'refs';
        *{"$class\::$name"}       = $sub;
        *{"$class\::${name}_xml"} = $xml_sub;

        # add shortcuts
        my $short = $name;
        if ( $short =~ s/attributes$/attrs/ ) {
            *{"$class\::$short"}       = $sub;
            *{"$class\::${short}_xml"} = $xml_sub;
        }
    }

    return;
}

sub mk_add_attrs {
    my ( $self, @names ) = @_;

    my $class = ref $self || $self;

    for my $name (@names) {
        my $sub = sub {
            my $self = shift;
            my %attrs = ( @_ == 1 ) ? %{ $_[0] } : @_;

            for ( keys %attrs ) {
                append_xml_attribute( $self->{$name}, $_, $attrs{$_} );
            }
            return $self;
        };
        my $xml_sub = sub {
            my $self = shift;
            my %attrs = ( @_ == 1 ) ? %{ $_[0] } : @_;

            my $method = "add_$name";

            return $self->$method(
                { map { $_, literal( $attrs{$_} ) } keys %attrs } );
        };
        no strict 'refs';
        *{"$class\::add_$name"}       = $sub;
        *{"$class\::add_${name}_xml"} = $xml_sub;

        # add shortcuts
        my $short = $name;
        if ( $short =~ s/attributes$/attrs/ ) {
            *{"$class\::add_$short"}       = $sub;
            *{"$class\::add_${short}_xml"} = $xml_sub;
        }
    }

    return;
}

sub mk_del_attrs {
    my ( $self, @names ) = @_;

    my $class = ref $self || $self;

    for my $name (@names) {
        my $sub = sub {
            my $self = shift;
            my %attrs = ( @_ == 1 ) ? %{ $_[0] } : @_;

            for ( keys %attrs ) {
                remove_xml_attribute( $self->{$name}, $_, $attrs{$_} );
            }
            return $self;
        };
        my $xml_sub = sub {
            my $self = shift;
            my %attrs = ( @_ == 1 ) ? %{ $_[0] } : @_;

            my $method = "del_$name";

            return $self->$method(
                { map { $_, literal( $attrs{$_} ) } keys %attrs } );
        };
        no strict 'refs';
        *{"$class\::del_$name"}       = $sub;
        *{"$class\::del_${name}_xml"} = $xml_sub;

        # add shortcuts
        my $short = $name;
        if ( $short =~ s/attributes$/attrs/ ) {
            *{"$class\::del_$short"}       = $sub;
            *{"$class\::del_${short}_xml"} = $xml_sub;
        }
    }

    return;
}

sub mk_add_methods {
    my ( $self, @names ) = @_;

    my $class = ref $self || $self;

    for my $name (@names) {
        my $sub = sub {
            my ( $self, $arg ) = @_;
            my @return;
            my $sub_name = "_single_$name";

            if ( ref $arg eq 'ARRAY' ) {
                push @return, map { $self->$sub_name($_) } @$arg;
            }
            else {
                push @return, $self->$sub_name($arg);
            }

            return @return == 1 ? $return[0] : @return;
        };

        no strict 'refs';

        *{"$class\::$name"} = $sub;
    }

    return;
}

sub mk_single_methods {
    my ( $self, @names ) = @_;

    my $class = ref $self || $self;

    for my $name (@names) {
        my $sub = sub {
            my ( $self, $arg ) = @_;
            my @items;

            if ( ref $arg eq 'HASH' ) {
                push @items, $arg;
            }
            elsif ( !ref $arg ) {
                push @items, { type => $arg };
            }
            else {
                croak 'invalid args';
            }

            my @return;

            for my $item (@items) {
                my @names = map { ref $_ ? @$_ : $_ }
                    grep {defined}
                    ( delete $item->{name}, delete $item->{names} );

                @names = uniq map { $_->name }
                    grep { defined $_->name } @{ $self->get_fields }
                    if !@names;

                croak "no field names to add $name to" if !@names;

                my $type = delete $item->{type};

                for my $x (@names) {
                    my $require_sub  = "_require_$name";
                    my $array_method = "_${name}s";

                    for my $field ( @{ $self->get_fields( { name => $x } ) } ) {
                        my $new = $field->$require_sub( $type, $item );
                        push @{ $field->$array_method }, $new;
                        push @return, $new;
                    }
                }
            }

            return @return;
        };

        no strict 'refs';

        *{"$class\::_single_$name"} = $sub;
    }

    return;
}

sub mk_require_methods {
    my ( $self, @names ) = @_;

    my $class = ref $self || $self;

    for my $name (@names) {
        my $sub = sub {
            my ( $self, $type, $opt ) = @_;

            croak 'required arguments: $self, $type, \%options' if @_ != 3;

            eval { my %x = %$opt };
            croak "options argument must be hash-ref" if $@;

            my $class = $type;
            if ( not $class =~ s/^\+// ) {
                $class = "HTML::FormFu::" . ucfirst($name) . "::$class";
            }

            $type =~ s/^\+//;

            require_class($class);

            my $object = $class->new( {
                    type   => $type,
                    parent => $self,
                } );

            weaken( $object->{parent} );

            # inlined ObjectUtil::populate(), otherwise circular dependency
            eval {
                map { $object->$_( $opt->{$_} ) } keys %$opt;
            };
            croak $@ if $@;

            return $object;
        };

        no strict 'refs';

        *{"$class\::_require_$name"} = $sub;
    }

    return;
}

sub mk_get_methods {
    my ( $self, @names ) = @_;

    my $class = ref $self || $self;

    for my $name (@names) {
        my $sub = sub {
            my $self       = shift;
            my %args       = _parse_args(@_);
            my $get_method = "get_${name}s";

            my @x = map { @{ $_->$get_method(@_) } } @{ $self->_elements };

            if ( exists $args{name} ) {
                @x = grep { $_->name eq $args{name} } @x;
            }

            if ( exists $args{type} ) {
                @x = grep { $_->type eq $args{type} } @x;
            }

            return \@x;
        };

        no strict 'refs';

        *{"$class\::get_${name}s"} = $sub;
    }

    return;
}

sub mk_get_one_methods {
    my ( $self, @names ) = @_;

    my $class = ref $self || $self;

    for my $name (@names) {
        my $sub = sub {
            my $self       = shift;
            my $get_method = "get_${name}s";

            my $x = $self->$get_method(@_);

            return @$x ? $x->[0] : ();
        };

        no strict 'refs';

        *{"$class\::get_$name"} = $sub;
    }

    return;
}

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

HTML::FormFu::Attribute

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head1 AUTHOR

Carl Franks, C<cfranks.org>

Based on the original source code of L<HTML::Widget::Accessor>, by 
Sebastian Riedel, C<sri@oook.de>.

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
