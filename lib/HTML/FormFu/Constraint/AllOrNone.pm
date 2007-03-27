package HTML::FormFu::Constraint::AllOrNone;

use strict;
use warnings;
use base 'HTML::FormFu::Constraint';

use Storable qw/ dclone /;

__PACKAGE__->mk_accessors(qw/ others /);

sub process {
    my ( $self, $params ) = @_;

    my $others = $self->others;
    return if !defined $others;

    my @names = ( $self->name );
    push @names, ref $others ? @{$others} : $others;
    my @errors;

    for my $name (@names) {
        my $seen  = 0;
        my $value = $params->{$name};
        if ( ref $value ) {
            eval { my @x = @$value };
            croak $@ if $@;

            my @errors = eval {
                $self->constrain_values( $value, $params );
                };
            $seen = 1 if !@errors && !$@;
        }
        else {
            my $ok = eval {
                $self->constrain_value($value);
                };
            $seen = 1 if $ok && !$@;
        }

        if ( !$seen ) {
            my $field = $self->form->get_field({ name => $name })
                or die "AllOrNone->others() field not found: '$name'";
            
            push @errors, HTML::FormFu::Exception::Constraint->new({
                parent => $field,
                });
        }
    }

    return ( scalar @errors == scalar @names )
        ? ()
        : @errors;
}

sub constrain_value {
    my ( $self, $value ) = @_;

    return 0 if !defined $value || $value eq '';

    return 1;
}

sub clone {
    my $self = shift;
    
    my $clone = $self->SUPER::clone(@_);
    
    $clone->others( dclone $self->others )
        if ref $self->others;
    
    return $clone;
}

1;

__END__

=head1 NAME

HTML::FormFu::Constraint::AllOrNone - AllOrNone constraint

=head1 SYNOPSIS

    type: AllOrNone
    name: foo
    others: [bar, baz]

=head1 DESCRIPTION

Ensure that either all or none of the named fields are present.

This constraint doesn't honour the C<not()> value.

=head1 METHODS

=head2 others

Arguments: \@field_names

=head1 SEE ALSO

Is a sub-class of, and inherits methods from L<HTML::FormFu::Constraint>

L<HTML::FormFu::FormFu>

=head1 AUTHOR

Carl Franks C<cfranks@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.
