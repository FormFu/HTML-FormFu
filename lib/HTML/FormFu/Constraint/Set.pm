package HTML::FormFu::Constraint::Set;

use strict;
use warnings;
use base 'HTML::FormFu::Constraint';

use Storable qw/ dclone /;

__PACKAGE__->mk_accessors(qw/ set /);

sub constrain_value {
    my ( $self, $value ) = @_;

    return 1 if !defined $value || $value eq '';

    my $set = $self->set;

    my %set = map { $_ => 1 } @$set;

    return exists $set{$value};
}

sub clone {
    my $self = shift;
    
    my $clone = $self->SUPER::clone(@_);
    
    $clone->{set} = dclone $self->set;
    
    return $clone;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::Set - Set constraint

=head1 SYNOPSIS

    $form->constraint( Set => 'foo' )->set([ 'yes', 'no' ]);

=head1 DESCRIPTION

The value must be in the specified set of values.

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu::FormFu>

=head1 METHODS

=head2 set

Arguments: \@allow_values

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
