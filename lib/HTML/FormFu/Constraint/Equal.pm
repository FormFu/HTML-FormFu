package HTML::FormFu::Constraint::Equal;

use strict;
use base 'HTML::FormFu::Constraint::_others';

sub process {
    my ( $self, $params ) = @_;

    # check when condition
    return unless $self->_process_when( $params );

    my $others = $self->others;
    return if !defined $others;

    my $name  = $self->name;
    my $value = $params->{$name};
    my @names = ref $others ? @{$others} : ($others);
    my @failed;

    for my $eq_name (@names) {

        my $ok = _values_eq( $value, $params->{$eq_name} );

        push @failed, $eq_name
            if $self->not ? $ok : !$ok;
    }

    return $self->mk_errors( {
            pass => @failed ? 0 : 1,
            failed => \@failed,
            names  => \@names,
        } );
}

sub _values_eq {
    my ( $v1, $v2 ) = @_;

    # the params should be coming from a CGI.pm compatible query object,
    # so the value is either a string or an arrayref of strings

    return 1 if !defined $v1 && !defined $v2;

    if ( !ref $v1 && !ref $v2 ) {
        return 1 if $v1 eq $v2;
    }
    elsif ( ref $v1 && ref $v2 ) {
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

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::Equal - Multi-field Equality Constraint

=head1 SYNOPSIS

    type: Equal
    name: password
    others: repeat_password

=head1 DESCRIPTION

All fields named in L</others> must have an equal value to the field this 
constraint is attached to.

=head1 SEE ALSO

Is a sub-class of, and inherits methods from  
L<HTML::FormFu::Constraint::_others>, L<HTML::FormFu::Constraint>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
