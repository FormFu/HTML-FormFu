package HTML::FormFu::Constraint::DependOn;

use strict;
use warnings;
use base 'HTML::FormFu::Constraint';

use Storable qw/ dclone /;

__PACKAGE__->mk_accessors(qw/ others /);

sub process {
    my ( $self, $form_result, $params ) = @_;

    my $others = $self->others;
    return if !defined $others;

    my $first = $self->name;
    my @names = ref $others ? @{$others} : ($others);
    my @errors;

    return if !$self->validate_value( $params->{$first} );

    for my $name (@names) {
        my $ok;
        my $value = $params->{$name};
        if ( ref $value ) {
            eval { my @x = @$value };
            croak $@ if $@;

            $ok = 1 if grep {$_} $self->validate_values($value);
        }
        else {
            $ok = $self->validate_value($value);
        }

        push @errors, $self->error( { name => $name } )
            if !$ok;
    }

    return \@errors;
}

sub validate_value {
    my ( $self, $value ) = @_;

    return 0 if !defined $value || $value eq '';

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

HTML::FormFu::Constraint::DependOn - DependOn constraint

=head1 SYNOPSIS

    $form->constraint( DependOn => 'foo', 'bar' );

=head1 DESCRIPTION

If the first named field is present, all remaining named fields must be 
present.

If the constraint fails, the first field will not display an error, but all 
other named fields will.

This constraint doesn't honour the C<not()> value, as it wouldn't make much 
sense.

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
