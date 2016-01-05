package HTML::FormFu::Constraint::Equal;

use Moose;
extends 'HTML::FormFu::Constraint';

with 'HTML::FormFu::Role::Constraint::Others';

use HTML::FormFu::Util qw(
    DEBUG_CONSTRAINTS
    debug
);
use List::MoreUtils qw( all );

our $EMPTY_STR = q{};

sub process {
    my ( $self, $params ) = @_;

    # check when condition
    return if !$self->_process_when($params);

    my $others = $self->others;
    return if !defined $others;

    my $value = $self->get_nested_hash_value( $params, $self->nested_name );

    DEBUG_CONSTRAINTS && debug( VALUE => $value );

    my @names = ref $others ? @{$others} : ($others);
    my @failed;
    my %values;

    for my $name (@names) {

        my $other_value = $self->get_nested_hash_value( $params, $name );

        DEBUG_CONSTRAINTS && debug( NAME => $name, VALUE => $value );

        my $ok = _values_eq( $value, $other_value );

        if ( $self->not ) {
            if ( $value eq $EMPTY_STR ) {

                # no error if both values are empty and not(1) is set
            }
            elsif ($ok) {
                push @failed, $name;
            }
        }
        elsif ( !$ok ) {
            push @failed, $name;
        }

        $values{$name} = $other_value;
    }

    # special case for $self->not()
    # no errors if all values are empty
    if (   $self->not
        && $value eq $EMPTY_STR
        && all { !defined || $_ eq $EMPTY_STR } values %values )
    {
        return;
    }

    return $self->mk_errors( {
            pass => @failed ? 0 : 1,
            failed => \@failed,
            names  => [ $self->nested_name, @names ],
        } );
}

sub _values_eq {
    my ( $v1, $v2 ) = @_;

    # the params should be coming from a CGI.pm compatible query object,
    # so the value is either a string or an arrayref of strings

    return 1 if !defined $v1 && !defined $v2;

    return if !defined $v1 || !defined $v2;

    if ( !ref $v1 && !ref $v2 ) {
        return 1 if $v1 eq $v2;
    }
    elsif ( ( ref $v1 eq 'ARRAY' ) && ( ref $v2 eq 'ARRAY' ) ) {
        return _arrays_eq( $v1, $v2 );
    }

    return;
}

sub _arrays_eq {
    my @a1 = sort @{ $_[0] };
    my @a2 = sort @{ $_[1] };

    return if scalar @a1 != scalar @a2;

    for my $i ( 0 .. $#a1 ) {
        return if $a1[$i] ne $a2[$i];
    }

    return 1;
}

sub _localize_args {
    my ($self) = @_;

    return $self->parent->label;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::Equal - Multi-field Equality Constraint

=head1 SYNOPSIS

    - type: Password
      name: password
      constraints:
      - type: Equal
        others: repeat_password
    - type: Password
      name: repeat_password

=head1 DESCRIPTION

All fields named in L<HTML::FormFu::Role::Constraint::Others/others> must have an equal value to the field this 
constraint is attached to.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from  
L<HTML::FormFu::Role::Constraint::Others>, L<HTML::FormFu::Constraint>

L<HTML::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
