package HTML::FormFu::Constraint::Equal;
use strict;
use warnings;
use base 'HTML::FormFu::Constraint';

use Exporter qw/ import /;
use Storable qw/ dclone /;

# only exported for use by test suite
our @EXPORT_OK = qw/ _values_eq /;

__PACKAGE__->mk_accessors(qw/ others /);

sub process {
    my ( $self, $params ) = @_;

    my $others = $self->others;
    return if !defined $others;

    my $name  = $self->name;
    my $value = $params->{$name};
    my @names = ref $others ? @{$others} : ($others);
    my @errors;

    for my $eq_name (@names) {

        my $ok = _values_eq( $value, $params->{$eq_name} );

        if ( $self->not ? $ok : !$ok ) {
            my $field = $self->form->get_field({ name => $eq_name })
                or die "Equal->others() field not found: '$eq_name'";
            
            push @errors, HTML::FormFu::Exception::Constraint->new({
                parent => $field,
                });
        }
    }

    return @errors;
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

sub clone {
    my $self = shift;
    
    my $clone = $self->SUPER::clone(@_);
    
    $clone->{others} = dclone $self->others if ref $self->others;
    
    return $clone;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::Equal - Equal constraint

=head1 SYNOPSIS

    $form->constraint( Equal => 'foo' )->others('bar');

=head1 DESCRIPTION

Ensure that all values are equal.

If the constraint fails, the first field will not display an error, but all 
other named fields will.

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
