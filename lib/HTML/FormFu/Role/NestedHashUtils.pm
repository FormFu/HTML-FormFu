use strict;

package HTML::FormFu::Role::NestedHashUtils;
# ABSTRACT: role for nested hashes

use Moose::Role;

use HTML::FormFu::Util qw( split_name );
use Carp qw( croak );

sub get_nested_hash_value {
    my ( $self, $param, $name ) = @_;

    my ( $root, @names ) = split_name($name);

    if ( !@names ) {
        return exists $param->{$root} ? $param->{$root} : undef;
    }

    my $ref = \$param->{$root};

    for (@names) {
        if (/^(0|[1-9][0-9]*)\z/) {
            croak "nested param clash for ARRAY $root"
                if ref $$ref ne 'ARRAY';

            return if $1 > $#{$$ref};

            $ref = \( $$ref->[$1] );
        }
        else {
            return if ref $$ref ne 'HASH' || !exists $$ref->{$_};

            $ref = \( $$ref->{$_} );
        }
    }

    return $$ref;
}

sub set_nested_hash_value {
    my ( $self, $param, $name, $value ) = @_;

    my ( $root, @names ) = split_name($name);

    if ( !@names ) {
        return $param->{$root} = $value;
    }

    my $ref = \$param->{$root};

    for (@names) {
        if (/^(0|[1-9][0-9]*)\z/) {
            $$ref = [] if !defined $$ref;

            croak "nested param clash for ARRAY $name"
                if ref $$ref ne 'ARRAY';

            $ref = \( $$ref->[$1] );
        }
        else {
            $$ref = {} if !defined $$ref;

            croak "nested param clash for HASH $name"
                if ref $$ref ne 'HASH';

            $ref = \( $$ref->{$_} );
        }
    }

    $$ref = $value;
}

sub delete_nested_hash_key {
    my ( $self, $param, $name ) = @_;

    my ( $root, @names ) = split_name($name);

    if ( !@names ) {
        delete $param->{$root};
        return;
    }

    my $ref = \$param->{$root};

    for my $i ( 0 .. $#names ) {
        my $name = $names[$i];

        if ( $name =~ /^(0|[1-9][0-9]*)\z/ ) {
            return if !defined $$ref;

            croak "nested param clash for ARRAY $name"
                if ref $$ref ne 'ARRAY';

            $ref = \( $$ref->[$1] );

            if ( $i == $#names ) {
                croak "can't delete hash key for an array";
            }
        }
        else {
            return if !defined $$ref;

            croak "nested param clash for HASH $name"
                if ref $$ref ne 'HASH';

            if ( $i == $#names ) {
                delete $$ref->{$name};
            }
            else {
                $ref = \( $$ref->{$name} );
            }
        }
    }

    return;
}

sub nested_hash_key_exists {
    my ( $self, $param, $name ) = @_;

    my ( $root, @names ) = split_name($name);

    if ( !@names ) {
        return ( defined($root) && exists( $param->{$root} ) );
    }

    my $ref = \$param->{$root};

    for my $i ( 0 .. $#names ) {
        my $part = $names[$i];

        if ( $part =~ /^(0|[1-9][0-9]*)\z/ ) {
            croak "nested param clash for ARRAY $root"
                if ref $$ref ne 'ARRAY';

            if ( $i == $#names ) {
                return $1 > $$ref->[$1] ? 1 : 0;
            }

            $ref = \( $$ref->[$1] );
        }
        else {
            if ( $i == $#names ) {
                return if !ref $$ref || ref($$ref) ne 'HASH';

                return exists $$ref->{$part} ? 1 : 0;
            }

            $ref = \( $$ref->{$part} );
        }
    }

    return;
}

1;
